import { v4 as uuid } from 'uuid'
import { defineStore } from 'pinia'
import { useStorage } from '@vueuse/core'
import diaryData from '../data/diary.json'
import type { DiaryEntry } from '#build/components'

// typedefinition for the diary entry object

export type DiaryEntry = {
  id: string
  date: string
  cardIds: number[]
  question: string
  interpretation: string
}

const useDiaryStore = defineStore('diaryStore', () => {

  const diary = useStorage('diary', diaryData)

  const getDiaryEntry = computed(() => {
    return (id: string) => {
      const entry = diary.value.entries.find(entry => entry.id === id)
      if (entry) return entry;
    }
  })

  const addDiaryEntry = () => {
    diary.value.entries.push(
      {
        id: uuid(),
        date: new Date().toISOString(),
        cardIds: [],
        question: '',
        interpretation: ''
      }
    )
  }

  function deleteDiaryEntry(id: string) {
    const index = diary.value.entries.findIndex((entry) => entry.id === id)
    diary.value.entries.splice(index, 1)
  }

  return {
    // State
    diary,
    // Getters
    getDiaryEntry,
    // Actions
    deleteDiaryEntry,
    addDiaryEntry
  }
})

export default useDiaryStore

