<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import DOMPurify from 'dompurify';
  import LL from '../../i18n/i18n-svelte';
  import { AppConfig } from '../../config';

  interface Comment {
    autor: string | null;
    data: string | null;
    texto: string;
  }

  interface Props {
    referenceId?: string;
    fallbackDescription?: string;
    onContentChange?: () => void;
  }

  let { referenceId = '', fallbackDescription = '', onContentChange = () => {} }: Props = $props();

  type Status = 'idle' | 'loading' | 'loaded' | 'login' | 'error';

  const acelerawebUrl: string = (AppConfig.AcelerawebURL || '').replace(/\/+$/, '');

  let status: Status = $state('idle');
  let description: string | null = $state(null);
  let comments: Comment[] = $state([]);

  function sanitize(html: string): string {
    return DOMPurify.sanitize(html, {
      FORBID_TAGS: ['style', 'font'],
      FORBID_ATTR: ['style', 'class', 'color', 'bgcolor'],
    });
  }

  function ticketKeyFrom(reference: string): number | null {
    const match = /^(\d+)/.exec(reference.trim());
    return match ? Number(match[1]) : null;
  }

  async function load(ticketKey: number) {
    status = 'loading';
    try {
      const response = await fetch(`${acelerawebUrl}/api/tickets/${ticketKey}/conteudo`, {
        credentials: 'include',
        headers: { accept: 'application/json' },
      });

      if (response.status === 401) {
        status = 'login';
        return;
      }

      if (!response.ok) {
        console.error('Falha ao buscar o conteudo da demanda no aceleraweb', response.status, await response.text());
        status = 'error';
        return;
      }

      const content = await response.json();
      description = typeof content.descricao === 'string' && content.descricao.trim() ? content.descricao : null;
      comments = Array.isArray(content.comentarios) ? content.comentarios : [];
      status = 'loaded';
    } catch (e) {
      console.error('Falha ao buscar o conteudo da demanda no aceleraweb', e);
      status = 'error';
    }
  }

  onMount(() => {
    const ticketKey = ticketKeyFrom(referenceId);
    if (acelerawebUrl && ticketKey) load(ticketKey);
  });

  $effect(() => {
    void status;
    void description;
    void comments;
    untrack(onContentChange);
  });

  function shortDate(value: string | null): string {
    return value ? value.slice(0, 16) : '';
  }
</script>

{#if status === 'loading'}
  <p class="mb-2 text-sm text-gray-500 dark:text-gray-400" aria-live="polite">{$LL.storyContentLoading()}</p>
{:else if status === 'login'}
  <p class="mb-2 text-sm text-amber-700 dark:text-amber-300">
    {$LL.storyContentLoginRequired()}
    <a
      href={`${acelerawebUrl}/login`}
      target="_blank"
      rel="noopener noreferrer"
      class="underline text-blue-800 hover:text-blue-600 dark:text-sky-400 dark:hover:text-sky-600"
    >
      {$LL.storyContentLogin()}
    </a>
  </p>
{:else if status === 'error'}
  <p class="mb-2 text-sm text-amber-700 dark:text-amber-300">{$LL.storyContentError()}</p>
{/if}

<div
  class="unreset dark:text-white"
  class:whitespace-pre-line={!(status === 'loaded' && description) && !/<[a-z]/i.test(fallbackDescription)}
>
  {@html sanitize(status === 'loaded' && description ? description : fallbackDescription)}
</div>

{#if status === 'loaded'}
  <div class="mt-6">
    <div class="font-bold mb-2 dark:text-gray-400">{$LL.storyComments()}</div>
    {#if comments.length === 0}
      <p class="text-sm text-gray-500 dark:text-gray-400">{$LL.storyNoComments()}</p>
    {:else}
      <ul class="space-y-3">
        {#each comments as comment, i (i)}
          <li class="rounded-lg border border-gray-200 dark:border-gray-700 p-3">
            <div class="mb-1 flex flex-wrap items-baseline gap-x-2 text-sm">
              {#if comment.autor}
                <span class="font-semibold text-gray-900 dark:text-white">{comment.autor}</span>
              {/if}
              {#if comment.data}
                <span class="text-gray-500 dark:text-gray-400">{shortDate(comment.data)}</span>
              {/if}
            </div>
            <div class="unreset dark:text-white">
              {@html sanitize(comment.texto)}
            </div>
          </li>
        {/each}
      </ul>
    {/if}
  </div>
{/if}
