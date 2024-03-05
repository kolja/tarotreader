
<template>
  <div>
    <h1>{{ diary.name }}</h1>
    <div v-for="entry in diary.entries" :key="entry.id">
      <h2>{{ entry.date }}</h2>
      <pre>{{ entry.cardIds }}</pre>
      <p>{{ entry.question }}</p>
      <p>{{ entry.interpretation }}</p>
    </div>
  </div>
</template>

<script setup lang="ts">
  import useDiaryStore from '../stores/diaryStore.ts'
  const diary = useDiaryStore().diary
  const title = ref('Tarot Diary')

  useHead({
    title: title,
    meta: [
      {
        name: 'description',
        content: 'Tarot diary'
      }
    ]
  })
</script>

