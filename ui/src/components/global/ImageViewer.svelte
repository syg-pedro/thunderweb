<script lang="ts">
  import { onMount, untrack } from 'svelte';
  import { ChevronLeft, ChevronRight, ExternalLink, RotateCcw, X, ZoomIn, ZoomOut } from '@lucide/svelte';
  import { createFocusTrap } from 'focus-trap';
  import LL from '../../i18n/i18n-svelte';

  interface Props {
    images: Array<{ src: string; alt?: string }>;
    startIndex?: number;
    close: () => void;
  }

  let { images, startIndex = 0, close }: Props = $props();

  const MIN_ZOOM = 1;
  const MAX_ZOOM = 5;
  const ZOOM_STEP = 0.5;

  let index = $state(untrack(() => startIndex));
  let zoom = $state(1);
  let offsetX = $state(0);
  let offsetY = $state(0);
  let dragging = $state(false);
  let dragStart = { x: 0, y: 0, offsetX: 0, offsetY: 0 };
  let swipeStartX: number | null = null;
  let moved = false;

  let current = $derived(images[index]);
  let hasMany = $derived(images.length > 1);

  let viewerElement: HTMLElement;

  function resetView() {
    zoom = 1;
    offsetX = 0;
    offsetY = 0;
  }

  function setZoom(value: number) {
    zoom = Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, value));
    if (zoom === MIN_ZOOM) {
      offsetX = 0;
      offsetY = 0;
    }
  }

  function go(step: number) {
    if (!hasMany) return;
    index = (index + step + images.length) % images.length;
    resetView();
  }

  function handleKeydown(e: KeyboardEvent) {
    const actions: Record<string, () => void> = {
      Escape: close,
      ArrowLeft: () => go(-1),
      ArrowRight: () => go(1),
      '+': () => setZoom(zoom + ZOOM_STEP),
      '=': () => setZoom(zoom + ZOOM_STEP),
      '-': () => setZoom(zoom - ZOOM_STEP),
      '0': resetView,
    };
    const action = actions[e.key];
    if (!action) return;
    e.preventDefault();
    e.stopImmediatePropagation();
    action();
  }

  function handleWheel(e: WheelEvent) {
    e.preventDefault();
    setZoom(zoom + (e.deltaY < 0 ? ZOOM_STEP : -ZOOM_STEP));
  }

  function handlePointerDown(e: PointerEvent) {
    moved = false;
    if (zoom > MIN_ZOOM) {
      dragging = true;
      dragStart = { x: e.clientX, y: e.clientY, offsetX, offsetY };
      (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
    } else {
      swipeStartX = e.clientX;
    }
  }

  function handlePointerMove(e: PointerEvent) {
    if (!dragging) return;
    moved = true;
    offsetX = dragStart.offsetX + (e.clientX - dragStart.x) / zoom;
    offsetY = dragStart.offsetY + (e.clientY - dragStart.y) / zoom;
  }

  function handlePointerUp(e: PointerEvent) {
    dragging = false;
    if (swipeStartX !== null) {
      const distance = e.clientX - swipeStartX;
      swipeStartX = null;
      if (Math.abs(distance) > 5) moved = true;
      if (Math.abs(distance) > 50) go(distance < 0 ? 1 : -1);
    }
  }

  function handleDoubleClick() {
    if (zoom > MIN_ZOOM) resetView();
    else setZoom(2);
  }

  onMount(() => {
    window.addEventListener('keydown', handleKeydown, true);
    const focusTrap = createFocusTrap(viewerElement, {
      escapeDeactivates: false,
      returnFocusOnDeactivate: true,
      allowOutsideClick: true,
    });
    focusTrap.activate();

    return () => {
      window.removeEventListener('keydown', handleKeydown, true);
      focusTrap.deactivate();
    };
  });

  const buttonClasses =
    'inline-flex items-center justify-center rounded-full p-2 text-white bg-black/50 hover:bg-black/75 focus:outline-none focus-visible:ring-2 focus-visible:ring-white disabled:opacity-40 disabled:cursor-not-allowed';
</script>

<div
  class="fixed inset-0 z-[200] flex flex-col bg-black/90 select-none"
  role="dialog"
  aria-modal="true"
  aria-label={$LL.imageViewer()}
  bind:this={viewerElement}
>
  <div class="flex items-center justify-between gap-2 p-3 text-white">
    <span class="text-sm tabular-nums" aria-live="polite">
      {#if hasMany}
        {$LL.imageCounter({ current: index + 1, total: images.length })}
      {/if}
    </span>

    <div class="flex items-center gap-2">
      <button
        type="button"
        class={buttonClasses}
        onclick={() => setZoom(zoom - ZOOM_STEP)}
        disabled={zoom <= MIN_ZOOM}
        aria-label={$LL.imageZoomOut()}
        title={$LL.imageZoomOut()}
      >
        <ZoomOut class="w-5 h-5" aria-hidden="true" />
      </button>
      <span class="w-12 text-center text-sm tabular-nums">{Math.round(zoom * 100)}%</span>
      <button
        type="button"
        class={buttonClasses}
        onclick={() => setZoom(zoom + ZOOM_STEP)}
        disabled={zoom >= MAX_ZOOM}
        aria-label={$LL.imageZoomIn()}
        title={$LL.imageZoomIn()}
      >
        <ZoomIn class="w-5 h-5" aria-hidden="true" />
      </button>
      <button
        type="button"
        class={buttonClasses}
        onclick={resetView}
        disabled={zoom === MIN_ZOOM}
        aria-label={$LL.imageZoomReset()}
        title={$LL.imageZoomReset()}
      >
        <RotateCcw class="w-5 h-5" aria-hidden="true" />
      </button>
      <a
        href={current.src}
        target="_blank"
        rel="noopener noreferrer"
        class={buttonClasses}
        aria-label={$LL.imageOpenOriginal()}
        title={$LL.imageOpenOriginal()}
      >
        <ExternalLink class="w-5 h-5" aria-hidden="true" />
      </a>
      <button type="button" class={buttonClasses} onclick={close} aria-label={$LL.close()} title={$LL.close()}>
        <X class="w-5 h-5" aria-hidden="true" />
      </button>
    </div>
  </div>

  <div class="relative flex-1 overflow-hidden">
    <!-- svelte-ignore a11y_no_static_element_interactions, a11y_click_events_have_key_events -->
    <div
      class="absolute inset-0 flex items-center justify-center touch-none {zoom > MIN_ZOOM
        ? dragging
          ? 'cursor-grabbing'
          : 'cursor-grab'
        : 'cursor-zoom-in'}"
      onwheel={handleWheel}
      onpointerdown={handlePointerDown}
      onpointermove={handlePointerMove}
      onpointerup={handlePointerUp}
      onpointercancel={handlePointerUp}
      ondblclick={handleDoubleClick}
      onclick={e => {
        if (!moved && e.target === e.currentTarget && zoom === MIN_ZOOM) close();
      }}
    >
      <img
        src={current.src}
        alt={current.alt ?? ''}
        draggable="false"
        class="max-h-full max-w-full object-contain {dragging ? '' : 'transition-transform duration-150'}"
        style="transform: scale({zoom}) translate({offsetX}px, {offsetY}px);"
      />
    </div>

    {#if hasMany}
      <button
        type="button"
        class="{buttonClasses} absolute left-3 top-1/2 -translate-y-1/2"
        onclick={() => go(-1)}
        aria-label={$LL.imagePrevious()}
        title={$LL.imagePrevious()}
      >
        <ChevronLeft class="w-7 h-7" aria-hidden="true" />
      </button>
      <button
        type="button"
        class="{buttonClasses} absolute right-3 top-1/2 -translate-y-1/2"
        onclick={() => go(1)}
        aria-label={$LL.imageNext()}
        title={$LL.imageNext()}
      >
        <ChevronRight class="w-7 h-7" aria-hidden="true" />
      </button>
    {/if}
  </div>
</div>
