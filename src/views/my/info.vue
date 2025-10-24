<template>
  <div class="user-profile-container">
    <el-card :title="T('Userinfo')" shadow="hover" class="profile-card">
      <el-form class="info-form" ref="form" :label-width="isMobile ? '100px' : '120px'" label-suffix="：">
        <el-form-item :label="T('Username')">
          <div class="form-value">{{ userStore.username }}</div>
        </el-form-item>
        <el-form-item :label="T('Email')">
          <div class="form-value">{{ userStore.email }}</div>
        </el-form-item>
        <el-form-item :label="T('Password')" prop="password">
          <el-button type="danger" @click="showChangePwd" :size="isMobile ? 'default' : 'default'" class="btn-change-pwd">
            {{ T('ChangePassword') }}
          </el-button>
        </el-form-item>
        <el-form-item label="OIDC" class="oidc-item">
          <!-- Desktop Table View -->
          <el-table v-if="!isMobile" :data="oidcData" border fit>
            <el-table-column :label="T('IdP')" prop="op" align="center"></el-table-column>
            <el-table-column :label="T('Status')" prop="status" align="center">
              <template #default="{ row }">
                <el-tag v-if="row.status === 1" type="success">{{ T('HasBind') }}</el-tag>
                <el-tag v-else type="danger">{{ T('NoBind') }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column :label="T('Actions')" align="center" width="200">
              <template #default="{ row }">
                <el-button v-if="row.status === 1" type="danger" size="small" @click="toUnBind(row)">
                  {{ T('UnBind') }}
                </el-button>
                <el-button v-else type="success" size="small" @click="toBind(row)">
                  {{ T('ToBind') }}
                </el-button>
              </template>
            </el-table-column>
          </el-table>

          <!-- Mobile Card View -->
          <div v-else class="oidc-mobile-list">
            <div v-for="row in oidcData" :key="row.op" class="oidc-card">
              <div class="oidc-header">
                <span class="oidc-label">{{ T('IdP') }}:</span>
                <strong class="oidc-op">{{ row.op }}</strong>
              </div>
              <div class="oidc-status">
                <span class="oidc-label">{{ T('Status') }}:</span>
                <el-tag v-if="row.status === 1" type="success" size="small">{{ T('HasBind') }}</el-tag>
                <el-tag v-else type="danger" size="small">{{ T('NoBind') }}</el-tag>
              </div>
              <div class="oidc-actions">
                <el-button 
                  v-if="row.status === 1" 
                  type="danger" 
                  size="small" 
                  @click="toUnBind(row)"
                  class="btn-full"
                >
                  {{ T('UnBind') }}
                </el-button>
                <el-button 
                  v-else 
                  type="success" 
                  size="small" 
                  @click="toBind(row)"
                  class="btn-full"
                >
                  {{ T('ToBind') }}
                </el-button>
              </div>
            </div>
            <el-empty v-if="!oidcData.length" :description="T('NoData')" :image-size="80" />
          </div>
        </el-form-item>
      </el-form>
    </el-card>
    
    <el-card shadow="hover" class="hello-card">
      <div class="markdown-content" v-html="html"></div>
    </el-card>
    
    <changePwdDialog v-model:visible="changePwdVisible"></changePwdDialog>
  </div>
</template>

<script setup>
import changePwdDialog from '@/components/changePwdDialog.vue'
import { computed, onMounted, ref } from 'vue'
import { useUserStore } from '@/store/user'
import { useAppStore } from '@/store/app'
import { bind, unbind } from '@/api/oauth'
import { myOauth } from '@/api/user'
import { ElMessageBox } from 'element-plus'
import { T } from '@/utils/i18n'
import { marked } from 'marked'

const appStore = useAppStore()
const userStore = useUserStore()
const changePwdVisible = ref(false)

// Mobile detection
const isMobile = ref(window.innerWidth <= 768)

const handleResize = () => {
  isMobile.value = window.innerWidth <= 768
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

const showChangePwd = () => {
  changePwdVisible.value = true
}

const oidcData = ref([])
const getMyOauth = async () => {
  const res = await myOauth().catch(_ => false)
  if (res) {
    oidcData.value = res.data
  }
}
getMyOauth()

const toBind = async (row) => {
  const res = await bind({ op: row.op }).catch(_ => false)
  if (res) {
    const { code, url } = res.data
    window.open(url)
  }
}

const toUnBind = async (row) => {
  const cf = await ElMessageBox.confirm(T('Confirm?', { param: T('UnBind') }), {
    confirmButtonText: T('Confirm'),
    cancelButtonText: T('Cancel'),
    type: 'warning',
  }).catch(_ => false)
  if (!cf) {
    return false
  }
  const res = await unbind({ op: row.op }).catch(_ => false)
  if (res) {
    getMyOauth()
  }
}

const html = computed(_ => marked(appStore.setting.hello || ''))
</script>

<style scoped lang="scss">
.user-profile-container {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
}

.profile-card {
  margin-bottom: 20px;
}

.info-form {
  width: 100%;
  max-width: 600px;
  margin: 0 auto;

  .form-value {
    color: #606266;
    font-size: 14px;
    line-height: 32px;
  }

  .btn-change-pwd {
    width: auto;
  }

  .oidc-item {
    :deep(.el-form-item__content) {
      display: block;
      width: 100%;
    }
  }
}

.hello-card {
  margin-top: 20px;

  .markdown-content {
    line-height: 1.8;
    color: #606266;
    font-size: 14px;

    :deep(h1),
    :deep(h2),
    :deep(h3),
    :deep(h4),
    :deep(h5),
    :deep(h6) {
      margin: 20px 0 10px;
      color: #303133;
      font-weight: 600;
    }

    :deep(h1) {
      font-size: 24px;
    }

    :deep(h2) {
      font-size: 20px;
    }

    :deep(h3) {
      font-size: 18px;
    }

    :deep(p) {
      margin: 10px 0;
    }

    :deep(ul),
    :deep(ol) {
      padding-left: 20px;
      margin: 10px 0;
    }

    :deep(code) {
      background-color: #f5f7fa;
      padding: 2px 6px;
      border-radius: 3px;
      font-family: 'Courier New', monospace;
      font-size: 13px;
    }

    :deep(pre) {
      background-color: #f5f7fa;
      padding: 15px;
      border-radius: 5px;
      overflow-x: auto;
      margin: 15px 0;

      code {
        background: none;
        padding: 0;
      }
    }

    :deep(a) {
      color: #409eff;
      text-decoration: none;

      &:hover {
        text-decoration: underline;
      }
    }

    :deep(blockquote) {
      border-left: 4px solid #dcdfe6;
      padding-left: 15px;
      margin: 15px 0;
      color: #909399;
    }
  }
}

/* OIDC Mobile Cards */
.oidc-mobile-list {
  width: 100%;
  margin-top: 10px;

  .oidc-card {
    background: #f9f9f9;
    border: 1px solid #ebeef5;
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 12px;
    transition: all 0.3s ease;

    &:hover {
      box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
    }

    &:last-child {
      margin-bottom: 0;
    }
  }

  .oidc-header {
    display: flex;
    align-items: center;
    margin-bottom: 12px;
    padding-bottom: 10px;
    border-bottom: 1px solid #ebeef5;

    .oidc-label {
      color: #909399;
      font-size: 13px;
      margin-right: 8px;
    }

    .oidc-op {
      color: #303133;
      font-size: 16px;
      flex: 1;
    }
  }

  .oidc-status {
    display: flex;
    align-items: center;
    margin-bottom: 12px;

    .oidc-label {
      color: #909399;
      font-size: 13px;
      margin-right: 8px;
      min-width: 60px;
    }
  }

  .oidc-actions {
    .btn-full {
      width: 100%;
    }
  }
}

/* Mobile Styles */
@media (max-width: 768px) {
  .user-profile-container {
    padding: 10px;
  }

  .info-form {
    max-width: 100%;
    padding: 0 10px;

    .el-form-item {
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      margin-bottom: 20px;

      :deep(.el-form-item__label) {
        width: 100% !important;
        text-align: left;
        padding: 0;
        margin-bottom: 8px;
        font-weight: 500;
      }

      :deep(.el-form-item__content) {
        width: 100%;
        margin-left: 0 !important;
      }
    }

    .form-value {
      width: 100%;
      padding: 10px;
      background-color: #f5f7fa;
      border-radius: 4px;
      word-break: break-all;
    }

    .btn-change-pwd {
      width: 100%;
    }
  }

  .hello-card {
    .markdown-content {
      font-size: 13px;
      padding: 10px;

      :deep(h1) {
        font-size: 20px;
      }

      :deep(h2) {
        font-size: 18px;
      }

      :deep(h3) {
        font-size: 16px;
      }

      :deep(pre) {
        padding: 10px;
        font-size: 12px;
      }

      :deep(img) {
        max-width: 100%;
        height: auto;
      }
    }
  }
}

/* Tablet Styles */
@media (max-width: 1024px) and (min-width: 769px) {
  .user-profile-container {
    padding: 15px;
  }

  .info-form {
    max-width: 700px;
  }
}

/* Touch optimization */
@media (hover: none) and (pointer: coarse) {
  .el-button,
  .oidc-card {
    -webkit-tap-highlight-color: transparent;
    touch-action: manipulation;
  }

  .oidc-card {
    &:active {
      transform: scale(0.98);
    }
  }
}

/* Dark mode support (optional) */
@media (prefers-color-scheme: dark) {
  .oidc-mobile-list {
    .oidc-card {
      background: #1f1f1f;
      border-color: #333;
    }
  }
}
</style>