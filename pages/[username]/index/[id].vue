<script setup>
  import useDiaryStore from '~/stores/diaryStore'
  import { useRoute } from 'vue-router'
  import { format } from 'date-fns'
  import { DatePicker } from 'v-calendar'
  import 'v-calendar/dist/style.css'
  const diary = useDiaryStore().diary
  const deleteDiaryEntry = useDiaryStore().deleteDiaryEntry
  const router = useRouter()
  const route = useRoute()

  const entryId = computed(() => {
    return route.params.id
  })

  const diaryEntry = computed(() => {
    return diary.entries.find(entry => entry.id === route.params.id)
  })  

  function deleteEntry() {
    deleteDiaryEntry(entryId)
    router.push(`/${route.params.username}`)
  }
</script>

<template>
  <section v-if="diaryEntry">
    <UCard class="diary-view content-center m-10 w-2/3">
      <UFormGroup label="Diary Entry">
        <h1>User: {{ route.params.username }}</h1>
        <h2>id: {{ route.params.id }}</h2>

        <UPopover :popper="{ placement: 'bottom-start' }">
          <UButton icon="i-heroicons-calendar-days-20-solid" :label="format(diaryEntry.date, 'MMM do, yyyy')" />
          <template #panel="{ close }">
            <DatePicker v-model="diaryEntry.date" @close="close" />
          </template>
        </UPopover>

        <UInput type="text" v-model="diaryEntry.question" class="mb-4"></UInput>
        <UTextarea v-model="diaryEntry.interpretation" class="mb-4"></UTextarea>
      </UFormGroup>
      <UButton
        class="items-end"
        icon="i-heroicons-trash-solid"
        color="red"
        @click="deleteEntry()"
      > Delete Entry
      </UButton>
    </UCard>
  </section>
  <section v-else>
    <UCard class="diary-view w-2/3">
      <h1>Entry not found</h1>
    </UCard>
  </section>
</template>
