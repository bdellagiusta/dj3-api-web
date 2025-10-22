<template>
  <div>
    <el-card class="list-query" shadow="hover">
      <h1 v-if="isHiperdino" class="title">Circuito de pantallas Canal Dino TV</h1>
      <el-form inline label-width="120px" :class="{ 'mobile-form': isMobile, 'centered-form': true }">
 
        <el-form-item :label="T('Name')">
          <el-input v-model="listQuery.alias" clearable @input="debouncedHandlerQuery"></el-input>
        </el-form-item>

        <el-form-item :label="T('Badge')">
          <el-select v-model="listQuery.collection_id" clearable @change="handlerQuery">
            <el-option :value="0" :label="T('MyAddressBook')" v-if="!isHiperdino"></el-option>
            <el-option v-for="c in collectionListRes.list" :key="c.id" :label="c.name" :value="c.id"></el-option>
          </el-select>
        </el-form-item>

        <el-form-item v-if="!isAdmin" :label="T('Islands')">
          <el-select v-model="listQuery.tag_id" clearable filterable :placeholder="T('Select island')" @change="handlerQuery">
            <el-option v-for="t in [...new Map(tagListRes.list.map(i => [i.name, i])).values()]" :key="t.id"
              :label="t.name" :value="t.name" />
          </el-select>
        </el-form-item>

        <el-form-item v-if="isAdmin" :label="T('Tags')">
          <el-select v-model="listQuery.tag_id" clearable filterable :placeholder="T('Select tags')" @change="handlerQuery">
            <el-option v-for="t in tagListRes.list" :key="t.id" :label="t.name" :value="t.name" />
          </el-select>
        </el-form-item>
        
        <el-form-item class="form-actions">
          <el-button v-if="isAdmin" type="danger" @click="toAdd">{{ T('Add') }}</el-button>
          <el-button v-if="isAdmin" type="primary" @click="showBatchEditTags">{{ T('BatchEditTags') }}</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- Vista Desktop: Tabla -->
    <el-card v-if="!isMobile" class="list-body" shadow="hover">
      <el-table :data="listRes.list" v-loading="listRes.loading" border @selection-change="handleSelectionChange">
        <el-table-column prop="alias" :label="T('Name')" align="center" />
        <el-table-column prop="id" label="ID" align="center" width="250">
          <template #default="{ row }">
            <div>
              <PlatformIcons :name="platformList.find(p => p.label === row.platform)?.icon"
                style="width: 20px;height: 20px;display: inline-block" color="var(--basicBlack)" />
              {{ row.id }}
              <el-icon @click="handleClipboard(row.id, $event)">
                <CopyDocument />
              </el-icon>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="collection_id" :label="T('Insignia')" align="center" width="250">
          <template #default="{ row }">
            <span v-if="row.collection_id === 0">{{ T('MyAddressBook') }}</span>
            <span v-else>{{collectionListRes.list.find(c => c.id === row.collection_id)?.name}}</span>
          </template>
        </el-table-column>
        <el-table-column v-if="isAdmin" prop="platform" :label="T('Platform')" align="center" width="250" />
        <el-table-column prop="tags" v-if="!isAdmin" :label="T('Island')" align="center" width="250" />
        <el-table-column prop="tags" v-if="isAdmin" :label="T('Tags')" align="center" width="250" />
        <el-table-column :label="T('Actions')" align="center" class-name="table-actions" fixed="right" width="250">
          <template #default="{ row }">
            <el-button type="success" @click="connectByClient(row.id)">{{ T('Link') }}</el-button>
            <template v-if="isAdmin">
              <el-button @click="toEdit(row)">{{ T('Edit') }}</el-button>
              <el-button type="danger" @click="del(row)">{{ T('Delete') }}</el-button>
            </template>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Vista Mobile: Cards -->
    <div v-else class="mobile-cards" v-loading="listRes.loading">
      <el-card v-for="row in listRes.list" :key="row.id" class="mobile-card" shadow="hover">

        <div class="mobile-card-header">
          <el-checkbox v-if="isAdmin" :model-value="isSelected(row)" @change="toggleSelection(row)"
            class="mobile-checkbox" />
          <h4 class="mobile-card-title">{{ row.alias }}</h4>
        </div>

        <div class="mobile-card-info">
          <div class="info-row">
            <span class="info-label">ID:</span>
            <div class="info-value">
              <PlatformIcons v-if="row.platform" :name="platformList.find(p => p.label === row.platform)?.icon"
                style="width: 16px;height: 16px;display: inline-block" color="var(--basicBlack)" />
              <span>{{ row.id }}</span>
              <el-icon @click="handleClipboard(row.id, $event)" class="copy-icon">
                <CopyDocument />
              </el-icon>
            </div>
          </div>

          <div v-if="row.collection_id !== undefined" class="info-row">
            <span class="info-label">{{ T('Badge') }}:</span>
            <span class="info-value">
              {{row.collection_id === 0 ? T('MyAddressBook') : collectionListRes.list.find(c => c.id ===
                row.collection_id)?.name }}
            </span>
          </div>

          <div v-if="isAdmin && row.platform" class="info-row">
            <span class="info-label">{{ T('Platform') }}:</span>
            <span class="info-value">{{ row.platform }}</span>
          </div>


          <div v-if="row.tags" class="info-row">
            <span class="info-label">{{ isAdmin ? T('Tags') : T('Island') }}:</span>
            <span class="info-value">{{ Array.isArray(row.tags) ? row.tags.join(', ') : row.tags }}</span>
          </div>
        </div>


        <div class="mobile-card-actions">
          <el-button type="success" @click="connectByClient(row.id)" class="action-btn-full">
            {{ T('Link') }}
          </el-button>
          <template v-if="isAdmin">
            <el-button @click="toEdit(row)" class="action-btn">{{ T('Edit') }}</el-button>
            <el-button type="danger" @click="del(row)" class="action-btn">{{ T('Delete') }}</el-button>
          </template>
        </div>
      </el-card>
    </div>

    <el-card class="list-page" shadow="hover">
      <el-pagination background :layout="isMobile ? 'prev, pager, next' : 'prev, pager, next, sizes, jumper'"
        :page-sizes="[10, 20, 50, 100]" :page-size="listQuery.page_size" :current-page="listQuery.page"
        :total="listRes.total" :small="isMobile" @size-change="handleSizeChange"
        @current-change="handleCurrentChange" />
    </el-card>

    <el-dialog v-model="formVisible" width="800" :title="!formData.row_id ? T('Create') : T('Update')"
      :fullscreen="isMobile">
      <el-form class="dialog-form" ref="form" :model="formData" label-width="120px">
        <el-form-item label="ID" prop="id" required>
          <el-input v-model="formData.id"></el-input>
        </el-form-item>
        <el-form-item :label="T('Name')" prop="alias">
          <el-input v-model="formData.alias"></el-input>
        </el-form-item>
        <el-form-item v-if="isAdmin" :label="T('Platform')" prop="platform">
          <el-select v-model="formData.platform">
            <el-option v-for="item in platformList" :key="item.value" :label="item.label"
              :value="item.value"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item v-if="!isAdmin" :label="T('Island')" prop="tags">
          <el-select v-model="formData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item v-if="isAdmin" :label="T('Tags')" prop="tags">
          <el-select v-model="formData.tags" multiple>
            <el-option v-for="item in tagListRes.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="formVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submit" type="primary">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>

    <el-dialog v-model="batchEditTagVisible" width="800" :fullscreen="isMobile">
      <el-form :model="batchEditTagsFormData" label-width="120px" class="dialog-form">
        <el-form-item :label="T('Tags')" prop="tags">
          <el-select v-model="batchEditTagsFormData.tags" multiple>
            <el-option v-for="item in tagListResForBatchEdit.list" :key="item.name" :label="item.name"
              :value="item.name"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="batchEditTagVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submitBatchEditTags" type="primary">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script setup>
import { onActivated, onMounted, ref, watch, computed, onUnmounted } from 'vue'
import { useBatchUpdateTagsRepositories, useRepositories } from '@/views/address_book'
import { T } from '@/utils/i18n'
// import shareByWebClient - NO SE USA
import { useAppStore } from '@/store/app'
import { connectByClient } from '@/utils/peer'
import { handleClipboard } from '@/utils/clipboard'
import { CopyDocument } from '@element-plus/icons'
import PlatformIcons from '@/components/icons/platform.vue'

// const appStore = useAppStore() - NO SE USA

const {
  listRes,
  listQuery,
  getList,
  getTagList,
  handlerQuery,
  collectionListRes,
  getCollectionList,
  del,
  formVisible,
  platformList,
  formData,
  toEdit,
  toAdd,
  submit,
  tagListRes,
  // changeCollectionForUpdate - NO SE USA
  getCollectionListForUpdate,
  // collectionListResForUpdate - NO SE USA
} = useRepositories('my')

const userInfo = computed(() => {
  const userStr = localStorage.getItem('user_info')
  return userStr ? JSON.parse(userStr) : null
})

const isAdmin = computed(() => userInfo.value?.name === 'admin')
const isHiperdino = computed(() => userInfo.value?.name === 'hiperdino')

// Detectar dispositivo móvil
const isMobile = ref(false)
const checkMobile = () => {
  isMobile.value = window.innerWidth < 768
}

// Debounce para el input de texto (espera 500ms después de que el usuario deje de escribir)
let debounceTimer = null
const debouncedHandlerQuery = () => {
  if (debounceTimer) {
    clearTimeout(debounceTimer)
  }
  debounceTimer = setTimeout(() => {
    handlerQuery()
  }, 500)
}

onMounted(() => {
  checkMobile()
  window.addEventListener('resize', checkMobile)
  getCollectionList()
  getCollectionListForUpdate()
  getList()
  getTagList()
})

onUnmounted(() => {
  window.removeEventListener('resize', checkMobile)
  if (debounceTimer) {
    clearTimeout(debounceTimer)
  }
})

onActivated(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

// Código comentado - no se usa en el template
// const shareToWebClientVisible = ref(false)
// const shareToWebClientForm = reactive({
//   id: '',
//   hash: '',
//   alias: '',
// })
// const toShowShare = (row) => { ... }

const {
  tagListRes: tagListResForBatchEdit,
  getTagList: getTagListForBatchEdit,
  visible: batchEditTagVisible,
  show: showBatchEditTags,
  formData: batchEditTagsFormData,
  submit: _submitBatchEditTags,
} = useBatchUpdateTagsRepositories()

onMounted(getTagListForBatchEdit)

const submitBatchEditTags = async () => {
  const res = await _submitBatchEditTags().catch(_ => false)
  if (res) {
    getList()
  }
}

const multipleSelection = ref([])
const handleSelectionChange = (val) => {
  multipleSelection.value = val
  batchEditTagsFormData.value.row_ids = val.map(v => v.row_id)
}

// Funciones para selección en móvil
const isSelected = (row) => {
  return multipleSelection.value.some(item => item.row_id === row.row_id)
}

const toggleSelection = (row) => {
  const index = multipleSelection.value.findIndex(item => item.row_id === row.row_id)
  if (index > -1) {
    multipleSelection.value.splice(index, 1)
  } else {
    multipleSelection.value.push(row)
  }
  batchEditTagsFormData.value.row_ids = multipleSelection.value.map(v => v.row_id)
}

const handleSizeChange = (val) => {
  listQuery.page_size = val
  listQuery.page = 1
  getList()
}

const handleCurrentChange = (val) => {
  listQuery.page = val
  getList()
}
</script>

<style scoped lang="scss">
.title {
  text-align: center;
  font-size: 2.5rem;
  font-weight: 700;
  padding-bottom: 2rem;
  text-shadow: 0 2px 6px rgba(0, 0, 0, 0.2);
}

// Centrar formulario de filtros
.list-query {
  :deep(.el-form) {
    &.centered-form {
      display: flex;
      justify-content: center;
      align-items: center;
      flex-wrap: wrap;
      
      .el-form-item {
        margin-right: 16px;
        margin-bottom: 16px;
      }
      
      .form-actions {
        margin-right: 0;
      }
    }
  }
}

// Estilos móviles para cards
.mobile-cards {
  display: flex;
  flex-direction: column;
  gap: 12px;
  padding: 15px 0px;
}

.mobile-card {
  border-radius: 8px;

  .mobile-card-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 1px solid #eee;

    .mobile-checkbox {
      flex-shrink: 0;
    }

    .mobile-card-title {
      font-size: 18px;
      font-weight: 600;
      margin: 0;
      flex: 1;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
  }

  .mobile-card-info {
    display: flex;
    flex-direction: column;
    gap: 8px;
    margin-bottom: 16px;

    .info-row {
      display: flex;
      align-items: center;
      font-size: 14px;

      .info-label {
        font-weight: 600;
        color: #cfd2d8;
        min-width: 80px;
      }

      .info-value {
        flex: 1;
        color: #e2e2e4;
        display: flex;
        align-items: center;
        gap: 6px;
        overflow: hidden;
        text-overflow: ellipsis;

        .copy-icon {
          cursor: pointer;
          flex-shrink: 0;

          &:hover {
            color: #409eff;
          }
        }
      }
    }
  }

  .mobile-card-actions {
    display: flex;
    gap: 8px;
    flex-wrap: wrap;

    .action-btn-full {
      flex: 1 1 100%;
    }

    .action-btn {
      flex: 1;
    }
  }
}

// Responsive para formularios
@media (max-width: 768px) {
  .title {
    font-size: 1.5rem;
    padding-bottom: 1rem;
  }

  .list-query {
    :deep(.el-form) {
      &.mobile-form {
        .el-form-item {
          display: flex;
          flex-direction: column;
          align-items: center;
          width: 100%;
          margin-right: 0;

          .el-form-item__label {
            width: 100% !important;
            text-align: center !important;
            margin-bottom: 8px;
            justify-content: center !important;
            display: flex !important;
          }

          .el-form-item__content {
            width: 100%;
            margin-left: 0 !important;
            display: flex;
            justify-content: center;
            
            .el-input,
            .el-select,
            .el-date-picker {
              text-align: center;
            }
          }
        }

        &.form-actions {
          display: flex;
          justify-content: center;
          flex-wrap: wrap;
          
          .el-button {
            flex: 1;
            margin: 4px;
          }
        }
      }
    }
  }

  .list-page {
    :deep(.el-pagination) {
      justify-content: center;
      flex-wrap: wrap;
    }
  }
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

    .dot {
      width: 10px;
      height: 10px;
      display: block;
      border-radius: 50%;
    }
  }
}
</style>