<template>
  <div class="tags-admin-container">
    <!-- Filter Card -->
    <el-card class="list-query" shadow="hover">
      <div class="mobile-header" v-if="isMobile">
  
        <el-button 
          class="filter-toggle" 
          color="#8B5CF6"
          @click="showFilters = !showFilters"
        >
          <el-icon v-if="showFilters"><Hide /></el-icon>
          <el-icon v-else><View /></el-icon>
          {{ showFilters ? T('Hide Filters') : T('Show Filters') }}
          <el-icon v-if="showFilters"><ArrowUp /></el-icon>
          <el-icon v-else><ArrowDown /></el-icon>
        </el-button>
      </div>
      
      <el-form v-show="!isMobile || showFilters" :inline="!isMobile" label-width="120px" class="filter-form">
        <el-form-item :label="T('Owner')" class="form-item-full">
          <el-select v-model="listQuery.user_id" clearable @change="changeUser">
            <el-option v-for="item in allUsers" :key="item.id" :label="item.username" :value="item.id"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item :label="T('AddressBookName')" class="form-item-full">
          <el-select v-model="listQuery.collection_id" clearable @change="changeCollection">
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListRes.list" :key="c.id" :label="c.name" :value="c.id"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item class="form-actions">
          <el-button :icon="CirclePlusFilled" type="primary" @click="toAdd" :class="{ 'btn-block': isMobile }">{{ T('Add') }}</el-button>
            <el-button type="danger" :icon="RefreshLeft" @click="clearFilters" :class="isMobile ? 'mobile-clear-btn' : 'desktop-clear-btn'">{{ T('Clear Filters') }}</el-button>

        </el-form-item>
      </el-form>
    </el-card>

    <!-- Desktop Table View -->
    <el-card v-if="!isMobile" class="list-body" shadow="hover">
      <el-table :data="listRes.list" v-loading="listRes.loading" border>
        <!-- <el-table-column prop="id" label="ID" align="center" /> -->
        <el-table-column prop="name" :label="T('Name')" align="center" />
        <el-table-column :label="T('Owner')" align="center">
          <template #default="{ row }">
            <span v-if="row.user_id"> <el-tag>{{allUsers?.find(u => u.id === row.user_id)?.username}}</el-tag> </span>
          </template>
        </el-table-column>
        <el-table-column prop="collection_id" :label="T('AddressBookName')" align="center">
          <template #default="{ row }">
            <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{ row.collection?.name }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="color" :label="T('Color')" align="center" width="100">
          <template #default="{ row }">
            <div class="colors">
              <div style="background-color: var(--tag-bg-color)" class="colorbox">
                <div :style="{ backgroundColor: row.color }" class="dot"></div>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" :label="T('CreatedAt')" align="center" />
        <el-table-column prop="updated_at" :label="T('UpdatedAt')" align="center" />
        <el-table-column :label="T('Actions')" align="center" width="250">
          <template #default="{ row }">
            <el-button :icon="Edit" type="warning" @click="toEdit(row)">{{ T('Edit') }}</el-button>
            <el-button :icon="DeleteFilled" type="danger" @click="del(row)">{{ T('Delete') }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Mobile Card View -->
    <div v-else class="mobile-list" v-loading="listRes.loading">
      <el-card v-for="row in listRes.list" :key="row.id" class="tag-card" shadow="hover">
        <div class="card-header">
          <div class="tag-preview">
            <div class="tag-colorbox" :style="{ backgroundColor: 'var(--tag-bg-color)' }">
              <div class="tag-dot" :style="{ backgroundColor: row.color }"></div>
            </div>
            <div class="tag-title">
              <strong class="tag-name">{{ row.name }}</strong>
              <span class="tag-owner" v-if="row.user_id">
                <el-tag size="small">{{allUsers?.find(u => u.id === row.user_id)?.username}}</el-tag>
              </span>
            </div>
          </div>
          <span class="tag-id">ID: {{ row.id }}</span>
        </div>

        <div class="card-content">
          <div class="info-row">
            <span class="label">{{ T('Owner') }}:</span>
            <span class="value">
              <el-tag size="small" v-if="row.user_id">
                {{allUsers?.find(u => u.id === row.user_id)?.username}}
              </el-tag>
              <span v-else>-</span>
            </span>
          </div>
          <div class="info-row">
            <span class="label">{{ T('AddressBookName') }}:</span>
            <span class="value">
              <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
              <span v-else>{{ row.collection?.name }}</span>
            </span>
          </div>
          <div class="info-row">
            <span class="label">{{ T('Color') }}:</span>
            <span class="value color-preview">
              <span class="color-code">{{ row.color }}</span>
              <span class="color-sample" :style="{ backgroundColor: row.color }"></span>
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
          <el-button :icon="Edit" type="warning" @click="toEdit(row)" size="small">{{ T('Edit') }}</el-button>
          <el-button :icon="DeleteFilled" type="danger" @click="del(row)" size="small">{{ T('Delete') }}</el-button>
        </div>
      </el-card>

      <el-empty v-if="!listRes.list.length && !listRes.loading" :description="T('NoData')" />
    </div>

    <!-- Pagination -->
    <el-card class="list-page" shadow="hover">
      <el-pagination background :layout="isMobile ? 'prev, pager, next' : 'prev, pager, next, sizes, jumper'"
        :page-sizes="[10, 20, 50, 100]" v-model:page-size="listQuery.page_size" v-model:current-page="listQuery.page"
        :total="listRes.total" :small="isMobile" />
    </el-card>

    <!-- Edit/Create Dialog -->
    <el-dialog v-model="formVisible" :title="!formData.id ? T('Create') : T('Update')"
      :width="isMobile ? '95%' : '800px'">
      <el-form class="dialog-form" ref="form" :model="formData" label-width="120px">
        <el-form-item :label="T('Owner')" prop="user_id" required>
          <el-select v-model="formData.user_id" @change="changeUserForUpdate">
            <el-option v-for="item in allUsers" :key="item.id" :label="item.username" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="T('AddressBookName')" prop="collection_id" required>
          <el-select v-model="formData.collection_id" clearable>
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListResForUpdate.list" :key="c.id" :label="c.name"
              :value="c.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="T('Name')" prop="name" required>
          <el-input v-model="formData.name"></el-input>
        </el-form-item>
        <el-form-item :label="T('Color')" prop="color" required>
          <div class="color-picker-wrapper">
            <el-color-picker v-model="formData.color" show-alpha @active-change="activeChange" />
            <div class="colors">
              <div style="background-color: var(--tag-bg-color)" class="colorbox">
                <div :style="{ backgroundColor: currentColor }" class="dot"></div>
              </div>
            </div>
          </div>
        </el-form-item>
        <el-form-item class="form-actions-dialog">
          <el-button @click="formVisible = false" :class="{ 'btn-block': isMobile }">{{ T('Cancel') }}</el-button>
          <el-button @click="submit" type="primary" :class="{ 'btn-block': isMobile }">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup>
import { onMounted, watch, onActivated, ref } from 'vue'
import { useRepositories } from '@/views/tag/index'
import { T } from '@/utils/i18n'
import { loadAllUsers } from '@/global'
import { ArrowDown, ArrowUp, DeleteFilled, CirclePlusFilled, Edit, Hide, View, RefreshLeft, Link, CopyDocument  } from '@element-plus/icons-vue'

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

const { allUsers, getAllUsers } = loadAllUsers()
onMounted(getAllUsers)

const {
  listRes,
  listQuery,
  getList,
  handlerQuery,
  del,
  formVisible,
  formData,
  toEdit,
  toAdd,
  submit,
  activeChange,
  currentColor,
  activeFiltersCount,

  collectionListRes,
  changeUser,
  changeCollection,

  collectionListResForUpdate,
  changeUserForUpdate,
} = useRepositories('admin')

onMounted(getList)
onActivated(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

// Función para limpiar todos los filtros
const clearFilters = () => {
  listQuery.collection_id = null
  listQuery.user_id = null
  listQuery.page = 1
  getList()
}

</script>

<style scoped lang="scss">
.tags-admin-container {
  padding: 10px;
}

.list-query {
  margin-bottom: 20px;

  .el-select {
    --el-select-width: 160px;
  }
}

.list-body {
  margin-bottom: 20px;
}

.colors {
  display: flex;
  justify-content: center;
  align-items: center;

  .colorbox {
    width: 50px;
    height: 30px;
    display: flex;
    justify-content: center;
    align-items: center;
    border-radius: 4px;

    .dot {
      width: 10px;
      height: 10px;
      display: block;
      border-radius: 50%;
    }
  }
}

@media (max-width: 768px) {
  .tags-admin-container {
    padding: 5px;
  }

  .mobile-header {

  .filter-toggle {
    width: 100%;
    padding: 1.2rem;  
    font-size:0.9rem;
    :deep(.el-icon) {
      margin-right: 8px;
      margin-left: 8px;
    }
  }
  }

  .filter-form {
    .el-form-item {
      display: block;
      margin: 15px 0;
      width: 100%;

      &.form-item-full {
        width: 100%;
      }

      // Asegurar que el label no reduzca el espacio del input
      :deep(.el-form-item__label) {
        width: 100%;
        text-align: left;
      }

      :deep(.el-form-item__content) {
        margin-left: 0 !important;
        margin-top: 1rem !important;
        width: 100%;
      }
    }

    .el-input,
    .el-select {
      width: 100% !important;
    }

    .form-actions {
      display: flex;
      flex-direction: column;
      gap: 10px;
      width: 100%;
      margin-left: 0 !important;

      .el-button {
        width: 100%;
        margin: 0.4rem 0 !important;
        padding: 1.1rem;
      }

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

  .tag-card {
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
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 12px;
    padding-bottom: 10px;
    border-bottom: 1px solid #ebeef5;

    .tag-preview {
      display: flex;
      align-items: flex-start;
      gap: 10px;
      flex: 1;

      .tag-colorbox {
        width: 40px;
        height: 30px;
        display: flex;
        justify-content: center;
        align-items: center;
        border-radius: 4px;
        flex-shrink: 0;
        margin-top: 2px;

        .tag-dot {
          width: 12px;
          height: 12px;
          border-radius: 50%;
        }
      }

      .tag-title {
        display: flex;
        flex-direction: column;
        gap: 6px;
        flex: 1;

        .tag-name {
          font-size: 16px;
          color: #ffffff;
          word-break: break-word;
          line-height: 1.4;
        }

        .tag-owner {
          .el-tag {
            font-size: 11px;
          }
        }
      }
    }

    .tag-id {
      font-size: 12px;
      color: #909399;
      flex-shrink: 0;
      margin-left: 10px;
      white-space: nowrap;
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
        min-width: 110px;
        font-size: 13px;
      }

      .value {
        color: #eaf0ff;
        flex: 1;
        text-align: right;
        word-break: break-all;
        font-size: 13px;

        &.color-preview {
          display: flex;
          align-items: center;
          justify-content: flex-end;
          gap: 8px;

          .color-code {
            font-family: 'Courier New', monospace;
            font-size: 12px;
            background: #000000;
            padding: 2px 6px;
            border-radius: 3px;
          }

          .color-sample {
            width: 24px;
            height: 24px;
            border-radius: 4px;
            border: 1px solid #dcdfe6;
            flex-shrink: 0;
          }
        }

        .el-tag {
          font-size: 12px;
        }
      }
    }
  }

  .card-actions {
    display: flex;
    flex-direction: column;
    gap: 10px;
    width: 100%;
    margin-top: 10px;

    .el-button {
      width: 100%;
      margin: 0;
      font-size: 0.9rem;
      padding: 1.1rem;
    }
  }
}

/* Dialog Styles */
.dialog-form {
  .el-form-item {
    margin-bottom: 18px;
    display: block !important;

    .el-select,
    .el-input {
      width: 100%;
    }
  }

  .color-picker-wrapper {
    display: flex;
    align-items: center;
    gap: 15px;
  }

  .form-actions-dialog {
    margin-top: 20px;
    margin-bottom: 0;

    :deep(.el-form-item__content) {
      display: block;
      gap: 10px;
    }

  }
}

@media (max-width: 768px) {
  :deep(.el-form-item__label) {
    width: auto !important;
    margin-top: 1rem;
  }

  .dialog-form {
    .el-form-item {
      display: flex;
      flex-direction: column;
      align-items: flex-start;

      :deep(.el-form-item__label) {
        width: 100% !important;
        text-align: left;
        padding: 0;
        display: block !important;
      }

      :deep(.el-form-item__content) {
        width: 100%;
        margin-left: 0 !important;
      }
    }

    .color-picker-wrapper {
      width: 100%;
      flex-direction: column;
      align-items: flex-start;
      gap: 10px;
    }

    .form-actions-dialog {
      :deep(.el-form-item__content) {
        flex-direction: column;
        width: 100%;
      }

      .btn-block {
        width: 100%;
        margin: 5px 0px !important;
        padding: 1.2rem;
      }
    }
  }

  :deep(.el-dialog) {
    margin: 10px !important;
    max-height: 90vh;
    overflow-y: auto;
  }

  :deep(.el-dialog__body) {
    padding: 15px;
  }
}

/* Tablet Styles */
@media (max-width: 1024px) and (min-width: 769px) {
  .tags-admin-container {
    padding: 15px;
  }
}

/* Touch optimization */
@media (hover: none) and (pointer: coarse) {

  .el-button,
  .tag-card {
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
</style>