<script lang="ts">
  import Modal from '../global/Modal.svelte';
  import LL from '../../i18n/i18n-svelte';
  import { ExternalLink } from '@lucide/svelte';
  import Badge from '../global/Badge.svelte';
  import ImageViewer from '../global/ImageViewer.svelte';
  import StoryAceleratoContent from './StoryAceleratoContent.svelte';

  interface Props {
    togglePlanView?: any;
    planName?: string;
    planType?: string;
    referenceId?: string;
    planLink?: string;
    description?: string;
    acceptanceCriteria?: string;
    priority?: number;
  }

  let {
    togglePlanView = () => {},
    planName = '',
    planType = '',
    referenceId = '',
    planLink = '',
    description = '',
    acceptanceCriteria = '',
    priority = 99,
  }: Props = $props();

  let contentElement: HTMLElement | undefined = $state();
  let viewerImages: Array<{ src: string; alt?: string }> = $state([]);
  let viewerIndex = $state(0);
  let showViewer = $state(false);
  let contentVersion = $state(0);

  type BadgeColor = 'gray' | 'blue' | 'red' | 'green' | 'orange' | 'yellow';

  const summary = $derived(parseSummary(description));

  function parseSummary(text: string): Array<{ label: string; value: string }> | null {
    const lines = text
      .split('\n')
      .map(line => line.trim())
      .filter(Boolean);
    if (!lines[0]?.startsWith('Ticket: ') || !lines.every(line => /^[^:<]+: \S/.test(line))) return null;
    return lines.map(line => {
      const index = line.indexOf(': ');
      return { label: line.slice(0, index), value: line.slice(index + 2) };
    });
  }

  function normalize(value: string): string {
    return value.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
  }

  function statusColor(status: string): BadgeColor {
    const name = normalize(status);
    if (/retorno|retrabalho|impedid|bloquead/.test(name)) return 'red';
    if (/conclu|finaliz|entregue/.test(name)) return 'green';
    if (/backlog|cancel/.test(name)) return 'gray';
    if (/aguardando/.test(name)) return 'yellow';
    return 'blue';
  }

  function effortColor(effort: string): BadgeColor {
    return Number(effort) > 0 ? 'green' : 'orange';
  }

  function contentImages(): HTMLImageElement[] {
    return contentElement ? Array.from(contentElement.querySelectorAll('img')) : [];
  }

  $effect(() => {
    void description;
    void acceptanceCriteria;
    void contentVersion;
    contentImages().forEach(img => {
      img.tabIndex = 0;
      img.setAttribute('role', 'button');
      img.setAttribute('aria-label', img.alt || $LL.imageViewer());
    });
  });

  function fullImageSrc(img: HTMLImageElement): string {
    const link = img.closest('a[rel="image"], a.image') as HTMLAnchorElement | null;
    return link?.href || img.currentSrc || img.src;
  }

  function openImage(target: EventTarget | null) {
    if (!(target instanceof HTMLImageElement)) return false;
    const images = contentImages();
    viewerImages = images.map(img => ({ src: fullImageSrc(img), alt: img.alt }));
    viewerIndex = Math.max(0, images.indexOf(target));
    showViewer = true;
    return true;
  }

  function handleContentClick(e: MouseEvent) {
    if (openImage(e.target)) e.preventDefault();
  }

  function handleContentKeydown(e: KeyboardEvent) {
    if ((e.key === 'Enter' || e.key === ' ') && openImage(e.target)) e.preventDefault();
  }

  const priorities: Record<number, { name: string; color: 'gray' | 'solidRed' | 'red' | 'orange' | 'yellow' | 'blue' }> = {
    99: {
      name: '',
      color: 'gray',
    },
    1: {
      name: $LL.planPriorityBlocker(),
      color: 'solidRed',
    },
    2: {
      name: $LL.planPriorityHighest(),
      color: 'red',
    },
    3: {
      name: $LL.planPriorityHigh(),
      color: 'orange',
    },
    4: {
      name: $LL.planPriorityMedium(),
      color: 'yellow',
    },
    5: {
      name: $LL.planPriorityLow(),
      color: 'blue',
    },
    6: {
      name: $LL.planPriorityLowest(),
      color: 'gray',
    },
  };
</script>

<Modal
  closeModal={togglePlanView}
  widthClasses="md:w-2/3 lg:w-3/5"
  ariaLabel={$LL.modalViewPokerStory()}
  closeOnBackdrop
>
  <div class="mb-4 dark:text-white">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planType()}
    </div>
    {planType}
  </div>
  <div class="mb-4 dark:text-white">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planName()}
    </div>
    {planName}
  </div>
  <div class="mb-4 dark:text-white">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planReferenceId()}
    </div>
    {referenceId}
  </div>
  <div class="mb-4">
    <div class="font-bold mb-2 dark:text-gray-400">{$LL.planLink()}</div>
    {#if planLink !== ''}
      <a
        href={planLink}
        target="_blank"
        class="text-blue-800 hover:text-blue-600 dark:text-sky-400 dark:hover:text-sky-600"
      >
        <ExternalLink class="inline-block" />
        {planLink}
      </a>
    {/if}
  </div>
  <div class="mb-4 dark:text-white">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planPriority()}
    </div>
    {#if priorities[priority]?.name}
      <Badge label={priorities[priority].name} color={priorities[priority].color} class="text-sm" />
    {/if}
  </div>
  {#if summary}
    <dl class="mb-4 grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 items-center dark:text-white">
      {#each summary as item, i (i)}
        <dt class="font-bold dark:text-gray-400">{item.label}</dt>
        <dd>
          {#if item.label === 'Status'}
            <Badge label={item.value} color={statusColor(item.value)} class="text-sm" />
          {:else if item.label === 'Esforço atual'}
            <Badge label={item.value} color={effortColor(item.value)} class="text-sm" />
          {:else}
            {item.value}
          {/if}
        </dd>
      {/each}
    </dl>
  {/if}
  <!-- svelte-ignore a11y_no_static_element_interactions -->
  <div
    bind:this={contentElement}
    onclick={handleContentClick}
    onkeydown={handleContentKeydown}
    class="[&_img]:cursor-zoom-in [&_img]:rounded [&_img:focus-visible]:outline [&_img:focus-visible]:outline-2 [&_img:focus-visible]:outline-sky-400"
  >
  <div class="mb-4">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planDescription()}
    </div>
    <StoryAceleratoContent {referenceId} fallbackDescription={summary ? '' : description} onContentChange={() => contentVersion++} />
  </div>
  <div class="mb-4">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planAcceptanceCriteria()}
    </div>
    <div class="unreset dark:text-white">
      {@html acceptanceCriteria}
    </div>
  </div>
  </div>

  {#if showViewer}
    <ImageViewer images={viewerImages} startIndex={viewerIndex} close={() => (showViewer = false)} />
  {/if}
</Modal>
