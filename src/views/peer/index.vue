<template>
<div class="peer-container">
    <!-- Filter Card with Modern Design -->
    <el-card class="list-query" shadow="hover">
      <div class="mobile-header" v-if="isMobile">
        <div class="filter-title">
          <el-icon class="filter-icon"><Filter /></el-icon>
          <el-badge :value="activeFiltersCount" v-if="activeFiltersCount > 0" class="filter-badge" />
        </div>
        <el-button 
          class="filter-toggle" 
          type="primary" 
          @click="showFilters = !showFilters"
          :icon="showFilters ? ArrowUp : ArrowDown"
        >
          {{ showFilters ? T('Hide Filters') : T('Show Filters') }}
        </el-button>
      </div>
      
      <el-form 
        v-show="!isMobile || showFilters" 
        :inline="!isMobile" 
        :label-width="isMobile ? 'auto' : '150px'"
        :label-position="isMobile ? 'top' : 'right'"
        class="filter-form"
        :class="{ 'mobile-centered': isMobile }"
      >
         <el-form-item :label="T('Name')" class="form-item-full">
          <el-input v-model="listQuery.alias" clearable :prefix-icon="Alias" />
        </el-form-item>
  
        

        <!-- Action Buttons -->
        <div class="action-buttons">
          <el-button type="primary" @click="toAdd" class="btn-action" :icon="Plus">
            {{ T('Add') }}
          </el-button>

          
          
          
          <el-button type="danger" @click="toBatchDelete" class="btn-action" :icon="Delete">
            {{ T('BatchDelete') }}
          </el-button>
        </div>
      </el-form>
    </el-card>


    <!-- Desktop Table View -->
    <el-card v-if="!isMobile" class="list-body" shadow="hover">
      <el-table :data="listRes.list" v-loading="listRes.loading" border size="small"
        @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" align="center" />
        <template v-for="c in visibleColumns.filter(cc => cc.visible)" :key="c">
          <el-table-column v-if="c.name === 'id'" prop="id" label="ID" align="center" width="150">
            
            <template #default="{ row }">
              <span>{{ row.id }} <el-icon @click="handleClipboard(row.id, $event)"><CopyDocument /></el-icon></span>
            </template>
          </el-table-column>
              <el-table-column v-if="c.name === 'alias'" prop="alias" label="Alias" align="center" width="100"
            show-overflow-tooltip />
          <el-table-column v-if="c.name === 'cpu'" prop="cpu" label="CPU" align="center" width="100"
            show-overflow-tooltip />
          <el-table-column v-if="c.name === 'memory'" prop="memory" :label="T('Memory')" align="center" width="120" />
          <el-table-column v-if="c.name === 'os'" prop="os" :label="T('Os')" align="center" width="120"
            show-overflow-tooltip />
          <el-table-column v-if="c.name === 'last_online_time'" prop="last_online_time" :label="T('LastOnlineTime')"
            align="center" min-width="120">
            <template #default="{ row }">
              <div class="last_oline_time">
                <span> {{ row.last_online_time ? timeAgo(row.last_online_time * 1000) : '-' }}</span> <span class="dot"
                  :class="{ red: timeDis(row.last_online_time) >= 60, green: timeDis(row.last_online_time) < 60 }"></span>
              </div>
            </template>
          </el-table-column>
          <el-table-column v-if="c.name === 'last_online_ip'" prop="last_online_ip" :label="T('LastOnlineIp')"
            align="center" min-width="120" />
          <el-table-column v-if="c.name === 'username'" prop="username" :label="T('Username')" align="center"
            width="120" />
          <el-table-column v-if="c.name === 'group_id'" prop="group_id" :label="T('Group')" align="center" width="120">
            <template #default="{ row }">
              <span v-if="row.group_id"> <el-tag>{{groupListRes.list?.find(g => g.id === row.group_id)?.name}}
                </el-tag> </span>
              <span v-else> - </span>
            </template>
          </el-table-column>
          <el-table-column v-if="c.name === 'uuid'" prop="uuid" :label="T('Uuid')" align="center" width="120"
            show-overflow-tooltip />
          <el-table-column v-if="c.name === 'version'" prop="version" :label="T('Version')" align="center" width="80" />
          <el-table-column v-if="c.name === 'alias'" prop="alias" :label="T('Alias')" align="center" width="80" />
          <el-table-column v-if="c.name === 'created_at'" prop="created_at" :label="T('CreatedAt')" align="center" 
            width="150" />
          <el-table-column v-if="c.name === 'updated_at'" prop="updated_at" :label="T('UpdatedAt')" align="center"
            width="150" />
        </template>

        <el-table-column :label="T('Actions')" align="center" width="500" class-name="table-actions" fixed="right">
          <template #default="{ row }">
            <el-button type="success" @click="connectByClient(row.id)">{{ T('Link') }}</el-button>
            <el-button type="primary" @click="toAddressBook(row)">{{ T('AddToAddressBook') }}</el-button>
            <el-button type="warning"  @click="toEdit(row)">{{ T('Edit') }}</el-button>
            <el-button type="danger" @click="del(row)">{{ T('Delete') }}</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- Mobile Card View -->
    <div v-else class="mobile-list" v-loading="listRes.loading">
      <el-card 
        v-for="row in listRes.list" 
        :key="row.id" 
        class="peer-card" 
        shadow="hover"
        @click="toggleSelection(row)"
      >
        <div class="card-header">
          <el-checkbox 
            :model-value="isSelected(row)" 
            @change="toggleSelection(row)"
            @click.stop
          />
          <div class="card-title">
            <strong>{{ row.hostname || row.id }}</strong>
            <span class="status-dot" :class="{ red: timeDis(row.last_online_time) >= 60, green: timeDis(row.last_online_time) < 60 }"></span>
          </div>
          <el-icon @click.stop="handleClipboard(row.id, $event)">
            <CopyDocument />
          </el-icon>
        </div>

        <div class="card-content">
          <div class="info-row">
            <span class="label">ID:</span>
            <span class="value">{{ row.id }}</span>
          </div>
          <div class="info-row" v-if="row.username">
            <span class="label">{{ T('Username') }}:</span>
            <span class="value">{{ row.username }}</span>
          </div>
          <div class="info-row" v-if="row.cpu">
            <span class="label">CPU:</span>
            <span class="value ellipsis" >{{ row.cpu }}</span>
          </div>
          <div class="info-row" v-if="row.memory">
            <span class="label">{{ T('Memory') }}:</span>
            <span class="value">{{ row.memory }}</span>
          </div>
          <div class="info-row" v-if="row.os">
            <span class="label">{{ T('Os') }}:</span>
            <span class="value ellipsis">{{ row.os }}</span>
          </div>
          <div class="info-row" v-if="row.last_online_time">
            <span class="label">{{ T('LastOnlineTime') }}:</span>
            <span class="value">{{ timeAgo(row.last_online_time * 1000) }}</span>
          </div>
          <div class="info-row" v-if="row.last_online_ip">
            <span class="label">IP:</span>
            <span class="value">{{ row.last_online_ip }}</span>
          </div>
          <div class="info-row" v-if="row.group_id">
            <span class="label">{{ T('Group') }}:</span>
            <el-tag size="small">{{ groupListRes.list?.find(g => g.id === row.group_id)?.name }}</el-tag>
          </div>
        </div>

        <div class="card-actions">
          <el-button size="small" type="success" @click.stop="connectByClient(row.id)">{{ T('Link') }}</el-button>
          <el-button size="small" type="primary" @click.stop="toAddressBook(row)">{{ T('AddToAddressBook') }}</el-button>
          <el-button size="small" type="warning" @click.stop="toEdit(row)">{{ T('Edit') }}</el-button>
          <el-button size="small" type="danger" @click.stop="del(row)">{{ T('Delete') }}</el-button>
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

    <!-- Edit Dialog -->

  <el-dialog
    v-model="formVisible"
    :title="!formData.row_id ? T('Create') : T('Update')"
    :width="isMobile ? '95%' : '800px'"
  >
    <el-form
      class="dialog-form"
      :class="{ 'mobile-dialog-form': isMobile }"
      ref="form"
      :model="formData"
      label-width="120px"
    >
      <el-form-item label="ID" prop="id" required>
        <el-input v-model="formData.id"></el-input>
      </el-form-item>

      <el-form-item :label="T('Name')" prop="alias">
        <el-input v-model="formData.alias"></el-input>
      </el-form-item>

      <el-form-item :label="T('Group')" prop="group_id">
        <el-select v-model="formData.group_id" placeholder="Select group">
          <el-option
            v-for="item in groupListRes.list"
            :key="item.id"
            :label="item.name"
            :value="item.id"
          ></el-option>
        </el-select>
      </el-form-item>

      <el-form-item :label="T('Username')" prop="username">
        <el-input v-model="formData.username"></el-input>
      </el-form-item>

      <el-form-item label="CPU" prop="cpu">
        <el-input v-model="formData.cpu"></el-input>
      </el-form-item>

      <el-form-item :label="T('Memory')" prop="memory">
        <el-input v-model="formData.memory"></el-input>
      </el-form-item>

      <el-form-item :label="T('Os')" prop="os">
        <el-input v-model="formData.os"></el-input>
      </el-form-item>

      <el-form-item class="dialog-actions">
        <el-button @click="formVisible = false">{{ T('Cancel') }}</el-button>
        <el-button type="primary" @click="submit">{{ T('Submit') }}</el-button>
      </el-form-item>
    </el-form>
  </el-dialog>

    <!-- Address Book Dialog -->
    <el-dialog v-model="ABFormVisible" :width="isMobile ? '95%' : '800px'" :title="T('Create')" destroy-on-close>
      <createABForm :peer="clickRow" @success="ABFormVisible = false" @cancel="ABFormVisible = false"></createABForm>
    </el-dialog>

    <!-- Batch Address Book Dialog -->
    <el-dialog v-model="batchABFormVisible" :width="isMobile ? '95%' : '800px'" :title="T('Create')">
      <el-form class="dialog-form" ref="form" :model="batchABFormData" label-width="120px">
        <el-form-item :label="T('Owner')" prop="user_id" required>
          <el-select v-model="batchABFormData.user_id" @change="changeUserForBatchCreateAB">
            <el-option v-for="item in allUsers" :key="item.id" :label="item.username" :value="item.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item :label="T('AddressBookName')" required prop="collection_id">
          <el-select v-model="batchABFormData.collection_id" clearable>
            <el-option :value="0" :label="T('MyAddressBook')"></el-option>
            <el-option v-for="c in collectionListResForBatchCreateAB.list" :key="c.id" :label="c.name"
              :value="c.id"></el-option>
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="batchABFormVisible = false">{{ T('Cancel') }}</el-button>
          <el-button @click="submitBatchAddToAB" type="primary">{{ T('Submit') }}</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>

    <!-- Column Settings Dialog -->
    <el-dialog v-model="columnSettingVisible" title="Column Setting" :width="isMobile ? '95%' : '600px'">
      <div v-for="(row, key) in visibleColumns" :key="key" class="column-setting-row">
        <div class="column-name">
          <el-checkbox v-model="row.visible" :label="true">{{ T(row.label) }}</el-checkbox>
        </div>
        <div class="column-controls">
          <el-icon @click="upColumn(key)" :size="20" class="control-icon">
            <ArrowUp />
          </el-icon>
          <el-icon @click="downColumn(key)" :size="20" class="control-icon">
            <ArrowDown />
          </el-icon>
        </div>
      </div>
      <template #footer>
        <el-button @click="columnSettingVisible = false">{{ T('Cancel') }}</el-button>
        <el-button type="primary" @click="saveColumnSetting">{{ T('Save') }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { computed, onActivated, onMounted, reactive, ref, watch } from 'vue'
import { batchRemove, create, list, remove, update } from '@/api/peer'
import { list as groupList } from '@/api/device_group'
import { ElMessage, ElMessageBox } from 'element-plus'
import { toWebClientLink } from '@/utils/webclient'
import { T } from '@/utils/i18n'
import { timeAgo } from '@/utils/time'
import { jsonToCsv, downBlob } from '@/utils/file'
import { loadAllUsers } from '@/global'
import { useAppStore } from '@/store/app'
import { connectByClient } from '@/utils/peer'
import { ArrowDown, ArrowUp, CopyDocument, Setting } from '@element-plus/icons'
import { handleClipboard } from '@/utils/clipboard'
import { batchCreateFromPeers } from '@/api/address_book'
import { useRepositories as useCollectionRepositories } from '@/views/address_book/collection'
import createABForm from '@/views/peer/createABForm.vue'
import { UploadFilled } from '@element-plus/icons-vue'

const appStore = useAppStore()

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

// Group
const groupListRes = reactive({
  list: [], total: 0, loading: false,
})
const groupListQuery = reactive({
  page: 1,
  page_size: 999,
})
const getGroupList = async () => {
  groupListRes.loading = true
  const res = await groupList(groupListQuery).catch(_ => false)
  groupListRes.loading = false
  if (res) {
    groupListRes.list = res.data.list
    groupListRes.total = res.data.total
  }
}
onMounted(getGroupList)

const listRes = reactive({
  list: [], total: 0, loading: false,
})
const listQuery = reactive({
  page: 1,
  page_size: 10,
  time_ago: null,
  id: '',
  username: '',
  ip: '',
})

const getList = async () => {
  listRes.loading = true
  const res = await list(listQuery).catch(_ => false)
  listRes.loading = false
  if (res) {
    listRes.list = res.data.list
    listRes.total = res.data.total
  }
}
const handlerQuery = () => {
  if (listQuery.page === 1) {
    getList()
  } else {
    listQuery.page = 1
  }
}

const del = async (row) => {
  const cf = await ElMessageBox.confirm(T('Confirm?', { param: T('Delete') }), {
    confirmButtonText: T('Confirm'),
    cancelButtonText: T('Cancel'),
    type: 'warning',
  }).catch(_ => false)
  if (!cf) {
    return false
  }

  const res = await remove({ row_id: row.row_id }).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    getList()
  }
}
onMounted(getList)
onActivated(getList)

watch(() => listQuery.page, getList)
watch(() => listQuery.page_size, handlerQuery)

const formVisible = ref(false)
const formData = reactive({
  row_id: 0,
  group_id: null,
  alias: '',
  cpu: '',
  id: '',
  memory: '',
  os: '',
  username: '',
  uuid: '',
  version: '',
})

const toEdit = (row) => {
  formVisible.value = true
  Object.keys(formData).forEach(key => {
    formData[key] = row[key]
  })
}
const toAdd = () => {
  formVisible.value = true
  formData.row_id = 0
  formData.alias
  formData.cpu = ''
  formData.id = ''
  formData.memory = ''
  formData.os = ''
  formData.username = ''
  formData.uuid = ''
  formData.version = ''
}
const submit = async () => {
  const api = formData.row_id ? update : create
  const res = await api(formData).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    formVisible.value = false
    getList()
  }
}

const timeDis = (time) => {
  let now = new Date().getTime()
  let after = new Date(time * 1000).getTime()
  return (now - after) / 1000
}

const timeFilters = computed(() => [
  { text: T('MinutesLess', { param: 1 }, 1), value: -60 },
  { text: T('HoursLess', { param: 1 }, 1), value: -3600 },
  { text: T('DaysLess', { param: 1 }, 1), value: -86400 },
  { text: '---------', value: 0 },
  { text: T('MinutesAgo', { param: 1 }, 1), value: 60 },
  { text: T('HoursAgo', { param: 1 }, 1), value: 3600 },
  { text: T('DaysAgo', { param: 1 }, 1), value: 86400 },
  { text: T('MonthsAgo', { param: 1 }, 1), value: 2592000 },
])

const toExport = async () => {
  const q = { ...listQuery }
  q.page_size = 10000
  q.page = 1
  const res = await list(q).catch(_ => false)
  if (res) {
    const data = res.data.list.map(item => {
      item.last_online_time = item.last_online_time ? new Date(item.last_online_time * 1000).toLocaleString() : '-'
      delete item.user_id
      delete item.user
      return item
    })
    const csv = jsonToCsv(data)
    downBlob(csv, 'peers.csv')
  }
}

const showImport = ref(false)
const canKeys = ['id', 'cpu',  'memory', 'os', 'username', 'uuid', 'version', 'group_id']
const parseCsv = (file) => {
  const reader = new FileReader()
  reader.onload = async (e) => {
    const data = e.target.result
    const rows = data.split('\n')
    const keys = rows[0].split(',')
    const values = rows.slice(1).map(row => {
      const obj = {}
      row.split(/,(?=(?:(?:[^"]*"){2})*[^"]*$)/).forEach((v, i) => {
        obj[keys[i]] = v.trim().replace(/^"|"$/g, '')
      })
      return obj
    }).filter(item => item.id)

    values.forEach(item => {
      item.group_id = parseInt(item.group_id)
      Object.keys(item).forEach(key => {
        if (!canKeys.includes(key)) {
          delete item[key]
        }
      })
    })
    const pa = values.map(item => create(item))
    const res = await Promise.all(pa).catch(_ => false)
    if (res) {
      ElMessage.success(T('OperationSuccess'))
      getList()
    }
  }
  reader.readAsText(file)
  return false
}

const ABFormVisible = ref(false)
const clickRow = ref({})
const toAddressBook = (row) => {
  clickRow.value = row
  ABFormVisible.value = true
}

const multipleSelection = ref([])
const handleSelectionChange = (val) => {
  multipleSelection.value = val
}

// Mobile selection handling
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
}

const toBatchDelete = async () => {
  if (!multipleSelection.value.length) {
    ElMessage.warning(T('PleaseSelectData'))
    return false
  }
  const cf = await ElMessageBox.confirm(T('Confirm?', { param: T('BatchDelete') }), {
    confirmButtonText: T('Confirm'),
    cancelButtonText: T('Cancel'),
    type: 'warning',
  }).catch(_ => false)
  if (!cf) {
    return false
  }

  const res = await batchRemove({ row_ids: multipleSelection.value.map(i => i.row_id) }).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    getList()
  }
}

const { allUsers, getAllUsers } = loadAllUsers()
onMounted(getAllUsers)
const {
  listRes: collectionListResForBatchCreateAB,
  listQuery: collectionListQueryForBatchCreateAB,
  getList: getCollectionListForBatchCreateAB,
} = useCollectionRepositories('admin')
collectionListQueryForBatchCreateAB.page_size = 9999
const changeUserForBatchCreateAB = (val) => {
  batchABFormData.value.collection_id = 0
  collectionListQueryForBatchCreateAB.user_id = val
  getCollectionListForBatchCreateAB()
}
const batchABFormVisible = ref(false)
const toBatchAddToAB = () => {
  batchABFormVisible.value = true
}
const batchABFormData = ref({
  collection_id: 0,
  tags: [],
  peer_ids: [],
  user_id: null,
})
const submitBatchAddToAB = async () => {
  if (multipleSelection.value.length === 0) {
    ElMessage.warning(T('PleaseSelectData'))
    return false
  }
  batchABFormData.value.peer_ids = multipleSelection.value.map(i => i.row_id)
  if (!batchABFormData.value.peer_ids.length) {
    ElMessage.warning(T('PleaseSelectData'))
    return false
  }

  const res = await batchCreateFromPeers(batchABFormData.value).catch(_ => false)
  if (res) {
    ElMessage.success(T('OperationSuccess'))
    batchABFormVisible.value = false
  }
}

const columnSettingVisible = ref(false)
const allColumns = ref([
  { name: 'id', visible: true, label: 'Id' },
  { name: 'cpu', visible: true, label: 'Cpu' },
  { name: 'memory', visible: true, label: 'Memory' },
  { name: 'os', visible: true, label: 'Os' },
  { name: 'last_online_time', visible: true, label: 'LastOnlineTime' },
  { name: 'last_online_ip', visible: true, label: 'LastOnlineIp' },
  { name: 'username', visible: true, label: 'Username' },
  { name: 'group_id', visible: true, label: 'Group' },
  { name: 'uuid', visible: true, label: 'Uuid' },
  { name: 'version', visible: true, label: 'Version' },
  { name: 'alias', visible: true, label: 'Alias' },
  { name: 'created_at', visible: true, label: 'CreatedAt' },
  { name: 'updated_at', visible: true, label: 'UpdatedAt' },
])
const visibleColumns = ref(JSON.parse(localStorage.getItem('peer_visible_columns')) || allColumns.value)
const showColumnSetting = () => {
  columnSettingVisible.value = true
}
const saveColumnSetting = () => {
  localStorage.setItem('peer_visible_columns', JSON.stringify(visibleColumns.value))
  ElMessage.success(T('OperationSuccess'))
  columnSettingVisible.value = false
}

const upColumn = (index) => {
  if (index === 0) return
  const col = visibleColumns.value[index]
  visibleColumns.value.splice(index, 1)
  visibleColumns.value.splice(index - 1, 0, col)
}
const downColumn = (index) => {
  if (index === visibleColumns.value.length - 1) return
  const col = visibleColumns.value[index]
  visibleColumns.value.splice(index, 1)
  visibleColumns.value.splice(index + 1, 0, col)
}

import debounce from 'lodash/debounce'

const debouncedGetList = debounce(getList, 300)

watch(() => listQuery.alias, debouncedGetList)
watch(() => listQuery.time_ago, debouncedGetList)

</script>

<style scoped lang="scss">
// peer-list.scss - Estilos separados para el componente Peer List

.peer-container {
  padding: 10px;
}

/* Mobile Styles */
@media (max-width: 768px) {
  .peer-container {
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
      margin-bottom: 0px;
      
      &.form-item-full {
        width: 100%;
      }
    }

    .el-input,
    .el-select {
      width: 100% !important;
    }
  }

  .action-buttons {
    display: flex;
    flex-direction: column;
    gap: 10px;
    width: 100%;
    margin-top: 10px;

    .el-button {
      width: 100%;
      margin: 0;
    }

    .btn-block {
      width: 100%;
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

  .dialog-form {
    .el-form-item {
      display: block;
      margin-bottom: 0px;
    }

    .el-input,
    .el-select {
      width: 100%;
    }
  }

  .csv-columns {
    font-weight: bold;
    font-size: 12px;
    word-break: break-all;
  }
}

/* Mobile Card List */
.mobile-list {
  margin-top: 10px;
  
  .peer-card {
    margin-bottom: 12px;
    cursor: pointer;
    transition: all 0.3s ease;

    &:hover {
      box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
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
    padding-bottom: 10px;
    border-bottom: 1px solid #ebeef5;

    .card-title {
      flex: 1;
      display: flex;
      align-items: center;
      gap: 8px;
      margin: 0 10px;
      
      strong {
        font-size: 16px;
        color: #f0f2f5;
        word-break: break-word;
      }
    }

    .status-dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      display: inline-block;
      flex-shrink: 0;
      
      &.red {
        background-color: #f56c6c;
        box-shadow: 0 0 6px rgba(245, 108, 108, 0.5);
      }
      
      &.green {
        background-color: #67c23a;
        box-shadow: 0 0 6px rgba(103, 194, 58, 0.5);
      }
    }

    .el-icon {
      cursor: pointer;
      font-size: 18px;
      color: #f3f3f3;
      transition: color 0.2s;
      
      &:hover {
        color: #409eff;
      }
      
      &:active {
        color: #3a8ee6;
        transform: scale(0.95);
      }
    }
  }

  .card-content {
    margin-bottom: 15px;

    .info-row {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 6px 0;
      font-size: 14px;

      &:not(:last-child) {
        border-bottom: 1px dashed #f0f0f0;
      }

      .label {
        color: #ecedee;
        font-weight: 500;
        min-width: 100px;
        font-size: 13px;
      }

      .value {
        color: #ececec;
        flex: 1;
        text-align: right;
        word-break: break-all;
        font-size: 13px;
      }
    }
  }

  .card-actions {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
    padding-top: 10px;
    border-top: 1px solid #ebeef5;

    .el-button {
      margin: 0;
      font-size: 12px;
      padding: 8px 10px;
      
      &:active {
        transform: scale(0.96);
      }
    }
  }
}

/* Desktop Styles */
.list-query {
  margin-bottom: 20px;

  .el-select {
    --el-select-width: 180px;
  }

  .el-form {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-end;
  }
}

.list-body {
  margin-bottom: 20px;

  .el-table {
    font-size: 13px;
  }
}

.last_oline_time {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
}

.dot {
  width: 6px;
  height: 6px;
  display: block;
  border-radius: 50%;
  margin-left: 10px;
  flex-shrink: 0;

  &.red {
    background-color: #f56c6c;
    box-shadow: 0 0 4px rgba(245, 108, 108, 0.4);
  }

  &.green {
    background-color: #67c23a;
    box-shadow: 0 0 4px rgba(103, 194, 58, 0.4);
  }
}

/* Column Settings */
.column-setting-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
  padding: 10px;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  transition: all 0.2s;

  &:hover {
    background-color: #f5f7fa;
    border-color: #d3d6db;
  }

  .column-name {
    flex: 1;

    .el-checkbox {
      font-weight: 500;
    }
  }

  .column-controls {
    display: flex;
    gap: 15px;

    .control-icon {
      cursor: pointer;
      color: #409eff;
      transition: all 0.2s;

      &:hover {
        transform: scale(1.2);
        color: #66b1ff;
      }

      &:active {
        transform: scale(0.9);
        color: #3a8ee6;
      }
    }
  }
}

/* Responsive adjustments for small tablets */
@media (max-width: 1024px) and (min-width: 769px) {
  .list-query .el-form {
    .el-form-item {
      margin-bottom: 0px;
    }
  }

  .action-buttons {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;

    .el-button {
      flex: 1 1 calc(50% - 4px);
      min-width: 150px;
    }
  }
}

/* Upload styles */
.upload-demo {
  width: 100%;

  .el-upload {
    width: 100%;
  }

  .el-upload-dragger {
    width: 100%;
  }
}

.el-upload__text {
  font-size: 14px;
  color: #ffffff;
  margin-top: 10px;
}

.el-upload__tip {
  font-size: 12px;
  color: #ffffff;
  line-height: 1.6;
  margin-top: 8px;
}

/* Dialog responsive */
@media (max-width: 768px) {
  :deep(.el-dialog) {
    margin: 10px !important;
    max-height: 90vh;
    overflow-y: auto;
    width: 95% !important;
  }

  :deep(.el-dialog__header) {
    padding: 15px;
  }

  :deep(.el-dialog__body) {
    padding: 15px;
    max-height: calc(90vh - 120px);
    overflow-y: auto;
  }

  :deep(.el-dialog__footer) {
    padding: 10px 15px;
    
    .el-button {
      width: calc(50% - 5px);
      margin: 0;
      
      &:first-child {
        margin-right: 10px;
      }
    }
  }
}

/* Pagination responsive */
.list-page {
  margin-top: 15px;
  
  .el-pagination {
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    
    @media (max-width: 768px) {
      padding: 10px 0;
      
      .el-pagination__sizes {
        display: none;
      }
      
      .el-pagination__jump {
        display: none;
      }
    }
  }
}

/* Loading state */
.el-loading-mask {
  background-color: rgba(255, 255, 255, 0.8);
}

/* Empty state */
.el-empty {
  padding: 40px 0;
  
  @media (max-width: 768px) {
    padding: 30px 0;
  }
}

/* Table actions column */
.table-actions {
  .cell {
    display: flex;
    gap: 8px;
    justify-content: center;
    flex-wrap: wrap;
  }
}

/* Selection highlight for mobile cards */
.mobile-list {
  .peer-card {
    position: relative;
    
    &.selected {
      border-color: #409eff;
      background-color: #ecf5ff;
    }
  }
}

/* Tag styles */
.el-tag {
  font-size: 12px;
  
  @media (max-width: 768px) {
    font-size: 11px;
    padding: 0 6px;
    height: 22px;
    line-height: 22px;
  }
}

/* Form item spacing */
.dialog-form {
  .el-form-item {
    margin-bottom: 10%;
    
    &:last-child {
      margin-bottom: 0;
      margin-top: 10px;
    }
  }


}

/* Button group spacing */
.action-buttons {
  .el-popover__reference {
    width: 100%;
    
    @media (max-width: 768px) {
      .el-button {
        width: 100%;
      }
    }
  }
}

/* Smooth scrolling */
* {
  scroll-behavior: smooth;
}

/* Touch optimization */
@media (hover: none) and (pointer: coarse) {
  .el-button,
  .el-icon,
  .peer-card {
    -webkit-tap-highlight-color: transparent;
    touch-action: manipulation;
  }
}

:deep(.el-button--small) {
  height: 38px;         /* altura deseada */
  line-height: 36px;    /* centra el texto verticalmente */
  padding: 6px 12px;    /* ajustar padding para mantener proporción */
  min-width: 48px;
  font-size: 13px;      /* opcional: ajustar tamaño de fuente */
}

.ellipsis {
  display: inline-block;
  max-width: 150px; /* ajusta según el diseño */
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  vertical-align: middle;
}  
.filter-form {

.el-form-item {
    margin-bottom: 0 !important;
}
}

@media (max-width: 768px) {

  .el-form-item__label {
    display: block !important;
  }
}
</style>
