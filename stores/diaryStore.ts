import { defineStore } from 'pinia'
import diaryData from '../data/diary.json'

const useDiaryStore = defineStore('diaryStore', () => {
  const diary = ref(diaryData)

  return {
    diary
  }
})

export default useDiaryStore

