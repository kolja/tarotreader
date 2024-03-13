
<template>
  <div class="tarot">
    <UContainer class="diary">
      <div class="diary-header">
        <UButton class="mb-3 right-0" icon="i-heroicons-plus-circle-solid" @click="addEntry()">Add Entry</UButton>
      </div>

      <h1>{{ username }}'s Tarot Diary</h1>
      <ul>
        <li v-for="entry in diary.entries" :key="entry.id" class="entry">
          <diaryEntry :entry="entry" @editDiaryEntry="editDiaryEntry"/>
        </li>
      </ul>
    </UContainer>
    <div class="tarot-bg" v-show="isModalOpen" @click.self="closeModal">
      <NuxtPage :key="route.fullPath" />
    </div>
  </div>
</template>

<script setup lang="ts">
  import useDiaryStore from '../stores/diaryStore.ts'
  import { v4 as uuid } from 'uuid'
  import { format } from 'date-fns'
  const diary = useDiaryStore().diary
  const title = ref('Tarot Diary')
  const router = useRouter()
  const route = useRoute()
  const username = router.currentRoute.value.params.username
  const isModalOpen = computed(() => {
    return route.name === 'username-index-id'
  })

  function addEntry() {
    diary.entries.push({
      id: uuid(),
      date: new Date().toISOString(),
      question: 'What is your question?',
      interpretation: 'What do the cards say?',
      cardIds: []
    })
  }

  function editDiaryEntry(id: string) {
    router.push(`/${username}/${id}`)
  }

  function closeModal() {
    router.push(`/${username}`)
  }
</script>

