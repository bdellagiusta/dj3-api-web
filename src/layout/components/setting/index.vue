<template>
  <div class="setting">
    <div class="menu-item">
    </div>
    
    <!-- Dropdown de idioma - OCULTO EN MOBILE -->
    <el-dropdown class="menu-item language-dropdown" trigger="click">
      <div class="title">
        <i class="el-icon el-tooltip__trigger language-icon">
          <svg preserveAspectRatio="xMidYMid meet" viewBox="0 0 24 24" width="1.2em" height="1.2em">
            <path fill="currentColor"
                  d="m18.5 10l4.4 11h-2.155l-1.201-3h-4.09l-1.199 3h-2.154L16.5 10h2zM10 2v2h6v2h-1.968a18.222 18.222 0 0 1-3.62 6.301a14.864 14.864 0 0 0 2.336 1.707l-.751 1.878A17.015 17.015 0 0 1 9 13.725a16.676 16.676 0 0 1-6.201 3.548l-.536-1.929a14.7 14.7 0 0 0 5.327-3.042A18.078 18.078 0 0 1 4.767 8h2.24A16.032 16.032 0 0 0 9 10.877a16.165 16.165 0 0 0 2.91-4.876L2 6V4h6V2h2zm7.5 10.885L16.253 16h2.492L17.5 12.885z"></path>
          </svg>
        </i>
      </div>
      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item 
            v-for="(v, k) in appStore.setting.langs" 
            @click="changeLang(k)" 
            :key="k"
          >
            {{ v.name }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
    
    <!-- Dropdown de usuario -->
    <el-dropdown class="menu-item user-dropdown" trigger="click">
      <div class="title">
        <span class="nickname">{{ user.username }}</span>
        <el-icon class="arrow-icon">
          <el-icon-arrow-down/>
        </el-icon>
      </div>

      <template #dropdown>
        <el-dropdown-menu>
          <el-dropdown-item @click="showChangePwd">
            {{ T('ChangePassword') }}
          </el-dropdown-item>
          <el-dropdown-item @click="logout">
            {{ T('Logout') }}
          </el-dropdown-item>
        </el-dropdown-menu>
      </template>
    </el-dropdown>
    
    <changePwdDialog v-model:visible="changePwdVisible"></changePwdDialog>
  </div>
</template>

<script setup>
  import { useUserStore } from '@/store/user'
  import { useAppStore } from '@/store/app'
  import changePwdDialog from '@/components/changePwdDialog.vue'
  import { ref } from 'vue'
  import { T } from '@/utils/i18n'
  import { useDark } from '@vueuse/core'

  const userStore = useUserStore()
  const user = userStore
  const appStore = useAppStore()

  const logout = () => {
    userStore.logout()
    window.location.reload()
  }

  const changePwdVisible = ref(false)
  const showChangePwd = () => {
    changePwdVisible.value = true
  }
  const changeLang = (v) => {
    appStore.changeLang(v)
  }
  const isDark = useDark()
</script>

<style lang="scss" scoped>
.setting {
  margin-left: auto;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 8px;
  padding-right: 8px;

  .menu-item {
    margin-left: 15px;

    * {
      outline: none;
    }
  }

  .title {
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: space-around;
    cursor: pointer;
    padding: 8px;
    border-radius: 4px;
    transition: background-color 0.3s;

    &:hover {
      background-color: rgba(255, 255, 255, 0.1);
    }

    .nickname {
      padding: 0 10px;
    }

    .language-icon {
      font-size: 24px;
    }

    .arrow-icon {
      margin-left: 4px;
    }
  }
}

// Responsive para mobile
@media (max-width: 768px) {
  .setting {
    gap: 4px;
    padding-right: 4px;
    
    // OCULTAR selector de idioma en mobile
    .language-dropdown {
      display: none;
    }

    .menu-item {
      margin-left: 8px;
    }

    .title {
      padding: 6px 10px;

      .nickname {
        padding: 0 8px;
        font-size: 15px;
        // Mantener visible el nombre en mobile
      }

      .language-icon {
        font-size: 20px;
      }

      .arrow-icon {
        margin-left: 6px;
        font-size: 14px;
      }
    }

    // Asegurar que el dropdown de usuario sea táctil
    .user-dropdown {
      -webkit-tap-highlight-color: transparent;
      
      .title {
        min-width: 100px;
        justify-content: center;
        
        &:active {
          background-color: rgba(255, 255, 255, 0.2);
        }
      }
    }
  }
}

// Para pantallas muy pequeñas
@media (max-width: 480px) {
  .setting {
    .title {
      padding: 6px 8px;
      
      .nickname {
        font-size: 14px;
        padding: 0 6px;
      }
      
      .arrow-icon {
        margin-left: 4px;
      }
    }
  }
}

// Para pantallas extremadamente pequeñas
@media (max-width: 375px) {
  .setting {
    .menu-item {
      margin-left: 4px;
    }

    .title {
      padding: 4px 6px;
      
      .nickname {
        font-size: 13px;
        padding: 0 4px;
      }
    }
  }
}
</style>