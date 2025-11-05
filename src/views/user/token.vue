<template>
  <div class="token-management">
    <el-card class="list-query" shadow="hover">


      <!-- Formulario de filtros -->
      <el-form 
        inline 
        label-width="80px" 
        class="query-form"
        :class="{ 'hidden-filters': isMobile && !showFilters }"
      >
        <el-form-item :label="T('User')" class="form-item-responsive">
          <el-select v-model="listQuery.user_id" clearable>
            <el-option 
              v-for="item in allUsers" 
              :key="item.id" 
              :label="item.username" 
              :value="item.id"
            ></el-option>
          </el-select>
        </el-form-item>
      </el-form>
    </el-card>
    
    <el-card class="list-body" shadow="hover">
      <!-- Vista de tabla para desktop -->
      <el-table 
        :data="listRes.list" 
        v-loading="listRes.loading" 
        border 
        @selection-change="handleSelectionChange"
        class="desktop-table"
      >
        <!-- <el-table-column prop="id" label="id" align="center" width="100" /> -->
        <el-table-column :label="T('Owner')" align="center">
          <template #default="{ row }">
            <span v-if="row.user_id"> 
              <el-tag>{{allUsers?.find(u => u.id === row.user_id)?.username}}</el-tag> 
            </span>
          </template>
        </el-table-column>
        <el-table-column :label="T('Token')" align="center">
          <template #default="{ row }">
            <span> {{ maskToken(row.token) }} </span>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" :label="T('CreatedAt')" align="center" />
        <el-table-column :label="T('ExpireTime')" prop="expired_at" align="center">
          <template #default="{ row }">
            <el-tag :type="expired(row) ? 'info' : 'success'">
              {{ row.expired_at ? new Date(row.expired_at * 1000).toLocaleString() : '-' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="T('Actions')" align="center" width="400">
          <template #default="{ row }">
            <el-button :icon="CircleCloseFilled" type="danger" @click="del(row)">{{ T('Logout') }}</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- Vista de cards para móvil -->
      <div class="mobile-cards" v-loading="listRes.loading">
        <div v-for="row in listRes.list" :key="row.id" class="mobile-card">
          <div class="card-header">
            <el-checkbox 
              :model-value="multipleSelection.some(item => item.id === row.id)"
              @change="toggleSelection(row)"
            />
            <span class="card-id">ID: {{ row.id }}</span>
          </div>
          
          <div class="card-content">
            <div class="card-row">
              <span class="label">{{ T('Owner') }}:</span>
              <el-tag v-if="row.user_id">
                {{ allUsers?.find(u => u.id === row.user_id)?.username }}
              </el-tag>
            </div>
            
            <div class="card-row">
              <span class="label">{{ T('Token') }}:</span>
              <span class="token-value">{{ maskToken(row.token) }}</span>
            </div>
            
            <div class="card-row">
              <span class="label">{{ T('CreatedAt') }}:</span>
              <span>{{ row.created_at }}</span>
            </div>
            
            <div class="card-row">
              <span class="label">{{ T('ExpireTime') }}:</span>
              <el-tag :type="expired(row) ? 'info' : 'success'">
                {{ row.expired_at ? new Date(row.expired_at * 1000).toLocaleString() : '-' }}
              </el-tag>
            </div>
          </div>
          
          <div class="card-actions">
            <el-button   :icon="CircleCloseFilled"  type="danger" @click="del(row)">
              {{ T('Logout') }}
            </el-button>
          </div>
        </div>
        
        <div v-if="!listRes.list || listRes.list.length === 0" class="empty-state">
          {{ T('NoData') || 'No data available' }}
        </div>
      </div>
    </el-card>
    
    <el-card class="list-page" shadow="hover">
      <el-pagination 
        background 
        layout="prev, pager, next, sizes, jumper" 
        :page-sizes="[10, 20, 50, 100]"
        v-model:page-size="listQuery.page_size" 
        v-model:current-page="listQuery.page" 
        :total="listRes.total"
        class="pagination-responsive"
      >
      </el-pagination>
    </el-card>
  </div>
</template>

<script setup>
import { computed, onActivated, onMounted, onUnmounted, ref, watch } from 'vue'
import { loadAllUsers } from '@/global'
import { useRepositories } from '@/views/user/token.js'
import { T } from '@/utils/i18n'
import {  ArrowDown,ArrowUp, CircleCloseFilled, DeleteFilled, Edit, Hide, View} from '@element-plus/icons-vue'

const { allUsers, getAllUsers } = loadAllUsers()
getAllUsers()

const {
  listRes,
  listQuery,
  getList,
  handlerQuery,
  del,
  batchDelete,
} = useRepositories()


onMounted(getList)
onActivated(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)
watch(() => listQuery.user_id, () => {
  listQuery.page = 1
  getList()
})



const maskToken = (token) => {
  return token.slice(0, 4) + '****' + token.slice(-4)
}

const expired = (row) => {
  const now = new Date().getTime()
  return row.expired_at * 1000 < now
}

const multipleSelection = ref([])

const handleSelectionChange = (val) => {
  multipleSelection.value = val
}

const toggleSelection = (row) => {
  const index = multipleSelection.value.findIndex(item => item.id === row.id)
  if (index > -1) {
    multipleSelection.value.splice(index, 1)
  } else {
    multipleSelection.value.push(row)
  }
}

const toBatchDelete = () => {
  if (multipleSelection.value.length === 0) {
    return
  }
  batchDelete(multipleSelection.value.map(v => v.id))
}

// Control de filtros móviles
const windowWidth = ref(window.innerWidth)

const isMobile = computed(() => windowWidth.value <= 768)

const activeFiltersCount = computed(() => {
  let count = 0
  if (listQuery.user_id) count++
  return count
})

const handleResize = () => {
  windowWidth.value = window.innerWidth
  // Mostrar filtros automáticamente en desktop
  if (!isMobile.value) {
    showFilters.value = false
  }
}

onMounted(() => {
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
})
</script>

<style scoped lang="scss">
.token-management {
  padding: 0;
}

.list-query {

  // Header móvil
  .mobile-header {
    display: none;
    justify-content: space-between;
    align-items: center;
    padding: 12px 0;
    border-bottom: 1px solid var(--el-border-color-light);

    .filter-info {
      display: flex;
      align-items: center;
      gap: 8px;

      .filter-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }

      .filter-text {
        font-weight: 500;
        color: var(--el-text-color-primary);
        font-size: 15px;
      }

      .filter-badge {
        :deep(.el-badge__content) {
          transform: translateY(-50%) translateX(50%);
        }
      }
    }
  .filter-toggle {
    width: 100%;
    padding: 1.2rem;
    
    :deep(.el-icon) {
      margin-right: 8px;
      margin-left: 8px;
    }
  }
  
  }

  .el-select {
    --el-select-width: 160px;
  }
}



.query-form:not(.hidden-filters) {
  max-height: 500px;
  opacity: 1;
  transition: all 0.3s ease;
}

// Vista móvil por defecto (ocultar tabla, mostrar cards)
.desktop-table {
  display: table;
}

.mobile-cards {
  display: none;
}

// Responsive para tablets y móviles
@media (max-width: 768px) {
  .mobile-header {
    display: flex !important;
  }

  .desktop-table {
    display: none;
  }

  .el-select {
    --el-select-width: 100% !important;
    width: 100% !important;
  }

  .el-button {
    margin-left: 0px !important;
    width: 100%;
    padding: 1.1rem;
   font-size: 0.9rem !important;
  }
  
  .mobile-cards {
    display: block;
    padding: 10px 0;
  }
  
  .mobile-card {
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
    padding: 16px;
    margin-bottom: 16px;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    
    .card-header {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 12px;
      padding-bottom: 12px;
      border-bottom: 1px solid var(--el-border-color-light);
      
      .card-id {
        font-weight: 600;
        color: var(--el-text-color-primary);
        font-size: 14px;
      }
    }
    
    .card-content {
      .card-row {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
        flex-wrap: wrap;
        gap: 8px;
        
        .label {
          font-weight: 500;
          color: var(--el-text-color-regular);
          font-size: 13px;
          min-width: 90px;
        }
        
        .token-value {
          font-family: monospace;
          font-size: 12px;
          color: var(--el-text-color-primary);
        }
      }
    }
    
    .card-actions {
      margin-top: 16px;
      padding-top: 12px;
      border-top: 1px solid var(--el-border-color-light);
      display: flex;
      justify-content: flex-end;
    }
  }
  
  .empty-state {
    text-align: center;
    padding: 40px 20px;
    color: var(--el-text-color-secondary);
  }
  
  // Formulario responsive
  .query-form {
    display: flex;
    flex-direction: column;
    
    .form-item-responsive {
      width: 100%;
      margin-right: 0 !important;
      
      .el-select {
        width: 100% !important;
        --el-select-width: 100% !important;
      }
      
      .el-button {
        width: 100%;
        margin-bottom: 8px;
      }
    }
  }
  
  // Paginación responsive
  .pagination-responsive {
    :deep(.el-pagination) {
      display: flex;
      flex-wrap: wrap;
      justify-content: center;
      gap: 8px;
      
      .el-pagination__sizes {
        margin: 0;
      }
      
      .el-pagination__jump {
        margin-left: 0;
      }
    }
  }
}

// Responsive para móviles pequeños
@media (max-width: 480px) {
  .list-query,
  .list-body,
  .list-page {
    margin: 8px;
  }
  
  .mobile-card {
    padding: 12px;
    
    .card-row {
      font-size: 12px;
      
      .label {
        font-size: 12px;
        min-width: 80px;
      }
    }
  }
  
  .pagination-responsive {
    :deep(.el-pagination) {
      .btn-prev,
      .btn-next,
      .el-pager li {
        min-width: 28px;
        height: 28px;
        line-height: 28px;
      }
    }
  }
}
</style>