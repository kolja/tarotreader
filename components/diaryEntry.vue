<script setup lang="ts">

import { format } from 'date-fns'
defineProps({
  entry: {
    type: Object,
    required: true,
  },
  onDelete: {
    type: Function,
    required: true,
  },
});

</script>

<template>
  <UCard class="mb-3">
    <strong>{{ format(entry.date, 'MMM do, yyyy')}}</strong>
    <UButton class="ml-5" icon="i-heroicons-pencil-solid" @click="$emit('editDiaryEntry', entry.id)"></UButton>
    <pre>{{ entry.cardIds }}</pre>
    <p>{{ entry.question }}</p>
    <p>{{ entry.interpretation }}</p>
  </UCard>
</template>
