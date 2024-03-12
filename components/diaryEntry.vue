<script setup lang="ts">
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
