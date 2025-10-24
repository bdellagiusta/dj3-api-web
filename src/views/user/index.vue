<template>
  <div class="users-container">
    <!-- Filter Card -->
    <el-card class="list-query" shadow="hover">
      <div class="mobile-header" v-if="isMobile">
        <el-button 
          class="filter-toggle" 
          type="primary" 
          @click="showFilters = !showFilters"
        >
          {{ showFilters ? T('HideFilters') : T('ShowFilters') }}
        </el-button>
      </div>

      <el-form 
        v-show="!isMobile || showFilters"
        :inline="!isMobile" 
        label-width="80px"
        class="filter-form"
      >
        <el-form-item :label="T('Username')" class="form-item-full">
          <el-input v-model="listQuery.username"></el-input>
        </el-form-item>
        <el-form-item class="form-actions">
          <el-button type="primary" @click="handlerQuery" :class="{ 'btn-block': isMobile }">{{ T('Filter') }}</el-button>
          <el-button type="danger" @click="toAdd" :class="{ 'btn-block': isMobile }">{{ T('Add') }}</el-button>
          <el-button type="success" @click="toExport" :class="{ 'btn-block': isMobile }">{{ T('Export') }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Desktop Table View -->
    <el-card v-if="!isMobile" class="list-body" shadow="hover">
      <el-table :data="listRes.list" v-loading="listRes.loading" border>
        <el-table-column prop="id" label="ID" align="center"></el-table-column>
        <el-table-column prop="username" :label="T('Username')" align="center" />
        <el-table-column :label="T('Group')" align="center">
          <template #default="{ row }">
            <span v-if="row.group_id"> <el-tag>{{listRes.groups?.find(g => g.id === row.group_id)?.name}} </el-tag>
            </span>
            <span v-else> - </span>
          </template>
        </el-table-column>
        <el-table-column :label="T('Status')" align="center">
          <template #default="{ row }">
            <el-switch v-model="row.status" :active-value="ENABLE_STATUS" :inactive-value="DISABLE_STATUS"
              @change="changeStatus(row)"></el-switch>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" :label="T('CreatedAt')" align="center" />
        <el-table-column prop="updated_at" :label="T('UpdatedAt')" align="center" />
        <el-table-column :label="T('Actions')" align="center" width="450">
          <template #default="{ row }">
            <el-button @click="toEdit(row)">{{ T('Edit') }}</el-button>
            <el-button type="warning" @click="changePass(row)">{{ T('ResetPassword') }}</el-button>
            <el-button type="danger" @click="remove(row)">{{ T('Delete') }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Mobile Card View -->
    <div v-else class="mobile-list" v-loading="listRes.loading">
      <el-card 
        v-for="row in listRes.list" 
        :key="row.id" 
        class="user-card" 
        shadow="hover"
      >
        <div class="card-header">
          <div class="user-info">
            <div class="user-avatar">
              <el-icon :size="28">
                <Avatar />
              </el-icon>
            </div>
            <div class="user-details">
              <strong class="user-name">{{ row.username }}</strong>
              <span class="user-id">ID: {{ row.id }}</span>
            </div>
          </div>
          <div class="user-status">
            <el-switch 
              v-model="row.status" 
              :active-value="ENABLE_STATUS" 
              :inactive-value="DISABLE_STATUS"
              @change="changeStatus(row)"
              size="small"
            />
          </div>
        </div>

        <div class="card-content">
          <div class="info-row">
            <span class="label">{{ T('Group') }}:</span>
            <span class="value">
              <el-tag size="small" v-if="row.group_id">
                {{ listRes.groups?.find(g => g.id === row.group_id)?.name }}
              </el-tag>
              <span v-else>-</span>
            </span>
          </div>
          <div class="info-row">
            <span class="label">{{ T('Status') }}:</span>
            <span class="value">
              <el-tag 
                :type="row.status === ENABLE_STATUS ? 'success' : 'danger'" 
                size="small"
              >
                {{ row.status === ENABLE_STATUS ? T('Enabled') : T('Disabled') }}
              </el-tag>
            </span>
          </div>
          <div class="info-row" v-if="row.created_at">
            <span class="label">{{ T('CreatedAt') }}:</span>
            <span class="value">{{ row.created_at }}</span>
          </div>
          <div class="info-row" v-if="row.updated_at">
            <span class="label">{{ T('UpdatedAt') }}:</span>
            <span class="value">{{ row.updated_at }}</span>
          </div>
        </div>

        <div class="card-actions">
          <el-button @click="toEdit(row)" size="small" class="action-btn">
            {{ T('Edit') }}
          </el-button>
          <el-button type="warning" @click="changePass(row)" size="small" class="action-btn">
            {{ T('ResetPassword') }}
          </el-button>
          <el-button type="danger" @click="remove(row)" size="small" class="action-btn">
            {{ T('Delete') }}
          </el-button>
        </div>
      </el-card>

      <el-empty v-if="!listRes.list.length && !listRes.loading" :description="T('NoData')" />
    </div>

    <!-- Pagination -->
    <el-card class="list-page" shadow="hover">
      <el-pagination 
        background 
        :layout="isMobile ? 'prev, pager, next' : 'prev, pager, next, sizes, jumper'" 
        :page-sizes="[10, 20, 50, 100]"
        v-model:page-size="listQuery.page_size" 
        v-model:current-page="listQuery.page" 
        :total="listRes.total"
        :small="isMobile"
      />
    </el-card>
  </div>
</template>

<script setup>
import { useRepositories, useDel, useToEditOrAdd, useChangePwd } from '@/views/user/composables'
import { T } from '@/utils/i18n'
import { DISABLE_STATUS, ENABLE_STATUS } from '@/utils/common_options'
import { update } from '@/api/user'
import { ElMessageBox, ElMessage } from 'element-plus'
import { onMounted, watch, ref } from 'vue'
import { Avatar } from '@element-plus/icons-vue'

// Mobile detection
const isMobile = ref(window.innerWidth <= 768)
const showFilters = ref(!isMobile.value)

const handleResize = () => {
  isMobile.value = window.innerWidth <= 768
  if (!isMobile.value) {
    showFilters.value = true
  }
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

const {
  listRes,
  listQuery,
  handlerQuery,
  getList,
  getGroups,
  toExport,
} = useRepositories()

onMounted(getGroups)
onMounted(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

const { toEdit, toAdd, toAddressBook, toTag } = useToEditOrAdd()
const { changePass } = useChangePwd()
const { del } = useDel()

const remove = async (row) => {
  const res = await del(row.id)
  if (res) {
    getList(listQuery)
  }
}

const changeStatus = async (row) => {
  const res = await update(row).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    getList(listQuery)
  }
}
</script>

<style scoped lang="scss">
.users-container {
  padding: 10px;
}

.list-query {
  margin-bottom: 20px;
}

.list-body {
  margin-bottom: 20px;
}

/* Mobile Styles */
@media (max-width: 768px) {
  .users-container {
    padding: 5px;
  }

  .mobile-header {
    margin-bottom: 15px;
    
    .filter-toggle {
      width: 100%;
    }
  }

  .filter-form {
    .el-form-item {
      display: block;
      margin-bottom: 15px;
      
      &.form-item-full {
        width: 100%;
      }
    }

    .el-input {
      width: 100% !important;
    }

    .form-actions {
      display: flex;
      flex-direction: column;
      gap: 10px;
      width: 100%;

      .btn-block {
        width: 100%;
        margin: 0;
      }
    }
  }

  .list-page {
    margin-top: 10px;
    
    .el-pagination {
      display: flex;
      justify-content: center;
      padding: 10px 0;
    }
  }
}

/* Mobile Card List */
.mobile-list {
  margin-top: 10px;
  
  .user-card {
    margin-bottom: 12px;
    transition: all 0.3s ease;

    &:hover {
      box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.15);
    }

    &:active {
      transform: scale(0.98);
    }
  }

  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
    padding-bottom: 12px;
    border-bottom: 1px solid #ebeef5;

    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
      flex: 1;

      .user-avatar {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        flex-shrink: 0;
        box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
      }

      .user-details {
        display: flex;
        flex-direction: column;
        gap: 4px;
        flex: 1;
        min-width: 0;

        .user-name {
          font-size: 16px;
          color: #303133;
          font-weight: 600;
          word-break: break-word;
        }

        .user-id {
          font-size: 12px;
          color: #909399;
        }
      }
    }

    .user-status {
      flex-shrink: 0;
      margin-left: 10px;
    }
  }

  .card-content {
    margin-bottom: 15px;

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 8px 0;
      font-size: 14px;

      &:not(:last-child) {
        border-bottom: 1px dashed #f0f0f0;
      }

      .label {
        color: #909399;
        font-weight: 500;
        min-width: 90px;
        font-size: 13px;
      }

      .value {
        color: #606266;
        flex: 1;
        text-align: right;
        word-break: break-all;
        font-size: 13px;

        .el-tag {
          font-size: 12px;
        }
      }
    }
  }

  .card-actions {
    display: flex;
    flex-direction: column;
    gap: 8px;
    padding-top: 12px;
    border-top: 1px solid #ebeef5;

    .action-btn {
      width: 100%;
      margin: 0;
      justify-content: center;
    }
  }
}

/* Desktop action buttons */
@media (min-width: 769px) {
  .el-table {
    .el-button {
      margin: 2px;
    }
  }
}

/* Tablet Styles */
@media (max-width: 1024px) and (min-width: 769px) {
  .users-container {
    padding: 15px;
  }

  .filter-form {
    .form-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;

      .el-button {
        flex: 1 1 calc(33.333% - 6px);
        min-width: 120px;
      }
    }
  }
}

/* Touch optimization */
@media (hover: none) and (pointer: coarse) {
  .el-button,
  .user-card {
    -webkit-tap-highlight-color: transparent;
    touch-action: manipulation;
  }
}

/* Empty state */
.el-empty {
  padding: 40px 0;
  
  @media (max-width: 768px) {
    padding: 30px 0;
  }
}

/* Switch in mobile card */
.user-status {
  .el-switch {
    transform: scale(0.9);
  }
}

/* Loading state */
.el-loading-mask {
  background-color: rgba(255, 255, 255, 0.8);
}

/* Avatar gradient variations (optional) */
.user-card:nth-child(3n+1) .user-avatar {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.user-card:nth-child(3n+2) .user-avatar {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.user-card:nth-child(3n+3) .user-avatar {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}
</style>