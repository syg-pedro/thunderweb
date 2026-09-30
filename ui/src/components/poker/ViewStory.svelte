<script lang="ts">
  import Modal from '../global/Modal.svelte';
  import LL from '../../i18n/i18n-svelte';
  import { ExternalLink } from '@lucide/svelte';
  import Badge from '../global/Badge.svelte';

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

<Modal closeModal={togglePlanView} widthClasses="md:w-2/3 lg:w-3/5" ariaLabel={$LL.modalViewPokerStory()}>
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
  <div class="mb-4">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planDescription()}
    </div>
    <div class="unreset dark:text-white">
      {@html description}
    </div>
  </div>
  <div class="mb-4">
    <div class="font-bold mb-2 dark:text-gray-400">
      {$LL.planAcceptanceCriteria()}
    </div>
    <div class="unreset dark:text-white">
      {@html acceptanceCriteria}
    </div>
  </div>
</Modal>
