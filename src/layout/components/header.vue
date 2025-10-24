<template>
  <div class="header-container">
    <!-- Botón hamburguesa para mobile (solo si es admin) -->
    <button 
      v-if="isMobile && isAdmin"
      class="hamburger-btn"
      @click="toggleDrawer"
      aria-label="Toggle menu"
    >
      <svg 
        xmlns="http://www.w3.org/2000/svg" 
        width="24" 
        height="24" 
        viewBox="0 0 24 24" 
        fill="none" 
        stroke="currentColor" 
        stroke-width="2" 
        stroke-linecap="round" 
        stroke-linejoin="round"
      >
        <line x1="3" y1="6" x2="21" y2="6"></line>
        <line x1="3" y1="12" x2="21" y2="12"></line>
        <line x1="3" y1="18" x2="21" y2="18"></line>
      </svg>
    </button>

    <div class="header-logo">
      <img :src="setting.logo" alt="" class="logo">
      <div class="title">Dj3 Networks</div>
    </div>
    
    <Setting></Setting>
  </div>
</template>

<script>
  import { defineComponent, computed, inject } from 'vue'
  import { storeToRefs } from 'pinia'  
  import HeaderMenu from '@/layout/components/menu/index.vue'
  import Setting from '@/layout/components/setting/index.vue'
  import { useAppStore } from '@/store/app'
  import GTags from '@/layout/components/tags/index.vue'

  export default defineComponent({
    name: 'LayerHeader',
    components: { HeaderMenu, Setting, GTags },
    emits: ['toggle-drawer'],
    props: {
      isMobile: {
        type: Boolean,
        default: false
      },
      isAdmin: {
        type: Boolean,
        default: false
      }
    },
    setup (props, { emit }) {
      const appStore = useAppStore()
      const { setting } = storeToRefs(appStore) 
      
      const expandOrFoldSlider = () => {
        appStore.sideCollapse()
      }

      const toggleDrawer = () => {
        emit('toggle-drawer')
      }

      return {
        setting,
        expandOrFoldSlider,
        toggleDrawer,
      }
    },
  })
</script>

<style scoped lang="scss">
  .header-container {
    display: flex;
    align-items: center;
    width: 100%;
    height: 100%;
    gap: 12px;
  }

  .hamburger-btn {
    background: none;
    border: none;
    color: white;
    cursor: pointer;
    padding: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 40px;
    width: 40px;
    border-radius: 4px;
    transition: background-color 0.3s ease;
    flex-shrink: 0;

    &:hover {
      background-color: rgba(255, 255, 255, 0.1);
    }

    &:active {
      background-color: rgba(255, 255, 255, 0.2);
      transform: scale(0.95);
    }

    svg {
      width: 24px;
      height: 24px;
    }

    // Efecto de tap en mobile
    @media (max-width: 768px) {
      -webkit-tap-highlight-color: transparent;
      
      &:active {
        transition: all 0.1s ease;
      }
    }
  }

  .ex-icon {
    height: 100%;
    display: flex;
    align-items: center;
    margin-right: 10px;
    font-size: 16px;
    cursor: pointer;
  }

  .header-logo {
    display: flex;
    height: 100%;
    align-items: center;
    flex-shrink: 0;

    .title {
      font-family: 'Century Gothic', sans-serif; 
      display: block;
      margin-left: 10px;
      white-space: nowrap;
      
      // Ocultar o reducir en móviles pequeños
      @media (max-width: 480px) {
        font-size: 14px;
        margin-left: 6px;
      }

      @media (max-width: 375px) {
        display: none;
      }
    }

    .logo {
      display: block;
      width: 30px;
      height: 30px;
      flex-shrink: 0;
      
      @media (max-width: 480px) {
        width: 26px;
        height: 26px;
      }
    }
  }
</style>