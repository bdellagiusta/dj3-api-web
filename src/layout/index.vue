<template>
  <el-config-provider :locale="appStore.setting.locale.value">
    <el-container :style="{'--sideBarWidth': sideBarWidth}">
      
      <!-- Sidebar Desktop -->
      <el-aside v-if="isAdmin && !isMobile" class="app-left">
        <g-aside></g-aside>
      </el-aside>

      <!-- Drawer Mobile -->
      <el-drawer
        class="drawer-mobile"
        v-if="isAdmin && isMobile"
        v-model="drawerVisible"
        direction="ltr"
        :size="280"
        :with-header="false"
        :modal="true"
      >
        <g-aside @close-drawer="drawerVisible = false"></g-aside>
      </el-drawer>

      <el-container class="app-container">
        <el-header class="app-header">
          <!-- Botón hamburguesa para mobile -->
          <button 
            v-if="isAdmin && isMobile" 
            class="hamburger-btn"
            @click="drawerVisible = true"
          >
            <i class="el-icon-menu"></i>
            ☰
          </button>
          <g-header></g-header>
        </el-header>
        
        <div class="header-tags">
          <tags></tags>
        </div>

        <el-main class="app-main">
          <router-view v-slot="{ Component }">
            <transition mode="out-in" name="el-fade-in-linear">
              <keep-alive :include="cachedTags">
                <component :is="Component"/>
              </keep-alive>
            </transition>
          </router-view>
        </el-main>
      </el-container>
    </el-container>
  </el-config-provider>
</template>

<script setup>
  import { useAppStore } from '@/store/app'
  import { useTagsStore } from '@/store/tags'
  import { ref, computed, onMounted, onUnmounted } from 'vue'
  import Tags from '@/layout/components/tags/index.vue'
  import GAside from '@/layout/components/aside.vue'
  import GHeader from '@/layout/components/header.vue'

  const appStore = useAppStore()
  const sideBarWidth = computed(() => appStore.setting.locale.sideBarWidth)
  
  const tagStore = useTagsStore()
  const cachedTags = ref([])
  cachedTags.value = tagStore.cached

  // Obtener información del usuario desde localStorage
  const userInfo = computed(() => {
    const userStr = localStorage.getItem('user_info')
    return userStr ? JSON.parse(userStr) : null
  })

  const currentUsername = computed(() => userInfo.value?.name || '')

  // Verificar si es admin
  const isAdmin = computed(() => userInfo.value?.name === 'admin')

  // Estado para mobile
  const isMobile = ref(false)
  const drawerVisible = ref(false)

  // Función para detectar si es mobile
  const checkMobile = () => {
    isMobile.value = window.innerWidth <= 768
    // Si cambiamos a desktop, cerramos el drawer
    if (!isMobile.value) {
      drawerVisible.value = false
    }
  }

  onMounted(() => {
    checkMobile()
    window.addEventListener('resize', checkMobile)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', checkMobile)
  })

  console.log('Current User:', currentUsername.value)
  console.log('Is Admin:', isAdmin.value)
</script>

<style lang="scss" scoped>
.app-header {
  background-color: #3f454b;
  color: var(--basicWhite);
  display: flex;
  align-items: center;
  height: 50px;
  position: relative;
}


.hamburger-btn {
  background: none;
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  padding: 0 15px;
  display: flex;
  align-items: center;
  height: 100%;
  transition: background-color 0.3s;

  &:hover {
  background-color: #2d3a4b;
  }

  &:active {
  background-color: #2d3a4b;
  }
}

.header-tags {
  height: auto;
  border-bottom: 1px solid #eee;
  display: flex;
  padding: 0;
}

.app-container {
  min-height: 100vh;
}

// Estilos responsive
@media (max-width: 768px) {
  .app-left {
    display: none;
      background-color: #2d3a4b;

  }
}

:deep(.el-drawer) {
  background-color: #2d3a4b !important;

}
:deep(.el-drawer__body) {
  padding: 25px 0 !important;
}



</style>