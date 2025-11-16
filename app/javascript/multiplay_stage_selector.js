// Multiplay recruitment stage selector with Popover API
// Provides tab-based stage selection with search functionality

function initStageSelector() {
  // 作成・編集フォーム用のポップオーバー
  const popover = document.querySelector('[data-stage-popover]');
  if (popover) {
    initFormStageSelector(popover);
  }

  // 検索フォーム用のポップオーバー
  const searchPopover = document.querySelector('[data-search-stage-popover]');
  if (searchPopover) {
    initSearchStageSelector(searchPopover);
  }
}

// 作成・編集フォーム用のステージセレクター
function initFormStageSelector(popover) {

  const guidField = document.querySelector('[data-stage-guid-field]');
  const manualGuidInput = document.querySelector('[data-manual-guid-input]');
  const stageSummary = document.getElementById('stage-selection-summary');
  const searchInput = document.querySelector('[data-stage-search-input]');
  const tabButtons = document.querySelectorAll('[data-stage-tab]');
  const tabContents = document.querySelectorAll('[data-stage-tab-content]');
  const noResultsDiv = document.getElementById('stage-no-search-results');

  // Tab switching
  tabButtons.forEach(button => {
    button.addEventListener('click', function() {
      const targetTab = this.getAttribute('data-stage-tab');

      // Update tab buttons
      tabButtons.forEach(btn => btn.classList.remove('active'));
      this.classList.add('active');

      // Update tab content
      tabContents.forEach(content => {
        if (content.getAttribute('data-stage-tab-content') === targetTab) {
          content.classList.add('active');
        } else {
          content.classList.remove('active');
        }
      });

      // Reset search when switching tabs
      if (searchInput) {
        searchInput.value = '';
        filterStages('');
      }
    });
  });

  // Stage selection (using event delegation)
  // Allow clicking on both the button and the stage item
  popover.addEventListener('click', function(e) {
    // First, check if a select button was clicked
    let selectButton = e.target.closest('[data-select-stage]');
    let stageItem = null;

    if (selectButton) {
      // Button was clicked - get data from button
      stageItem = selectButton.closest('[data-stage-item]');
    } else {
      // Check if stage item was clicked
      stageItem = e.target.closest('[data-stage-item]');
    }

    if (!stageItem) return;

    const stageGuid = stageItem.getAttribute('data-stage-guid');
    const stageTitle = stageItem.getAttribute('data-stage-title');

    // Update hidden field
    guidField.value = stageGuid;

    // Clear manual input field to prevent conflict
    if (manualGuidInput) {
      manualGuidInput.value = '';
    }

    // Update summary display
    stageSummary.innerHTML = `
      <span class="stage-selected-badge">
        ${stageTitle} (GUID: ${stageGuid})
        <button type="button" class="stage-clear-button" data-stage-clear>×</button>
      </span>
    `;

    // Re-attach clear button listener
    attachClearListener();

    // Close popover
    popover.hidePopover();
  });

  // Clear selection
  function attachClearListener() {
    const clearBtn = document.querySelector('[data-stage-clear]');
    if (clearBtn) {
      clearBtn.addEventListener('click', function() {
        guidField.value = '';
        if (manualGuidInput) {
          manualGuidInput.value = '';
        }
        stageSummary.innerHTML = '<span class="text-muted">ステージが選択されていません</span>';
      });
    }
  }
  attachClearListener();

  // Manual GUID input
  if (manualGuidInput) {
    manualGuidInput.addEventListener('input', function() {
      const guid = this.value;
      guidField.value = guid;

      if (guid) {
        stageSummary.innerHTML = `
          <span class="stage-selected-badge">
            GUID: ${guid}
            <button type="button" class="stage-clear-button" data-stage-clear>×</button>
          </span>
        `;
        attachClearListener();
      } else {
        stageSummary.innerHTML = '<span class="text-muted">ステージが選択されていません</span>';
      }
    });
  }

  // Search functionality
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      const keyword = this.value.toLowerCase();
      filterStages(keyword);
    });
  }

  function filterStages(keyword) {
    const activeTab = document.querySelector('[data-stage-tab].active').getAttribute('data-stage-tab');
    const stageItems = document.querySelectorAll(`[data-stage-tab-content="${activeTab}"] [data-stage-item]`);

    let visibleCount = 0;

    stageItems.forEach(item => {
      const title = item.getAttribute('data-stage-title').toLowerCase();
      const guid = item.getAttribute('data-stage-guid');

      if (title.includes(keyword) || guid.includes(keyword)) {
        item.style.display = '';
        visibleCount++;
      } else {
        item.style.display = 'none';
      }
    });

    // Show/hide no results message
    if (visibleCount === 0 && keyword !== '') {
      noResultsDiv.style.display = 'block';
    } else {
      noResultsDiv.style.display = 'none';
    }
  }

  // Reset search when popover is opened
  popover.addEventListener('toggle', function(e) {
    if (e.newState === 'open') {
      if (searchInput) {
        searchInput.value = '';
        filterStages('');
      }
    }
  });
}

// 検索フォーム用のステージセレクター
function initSearchStageSelector(popover) {
  const guidField = document.getElementById('search-stage-guid-field');
  const stageSummary = document.getElementById('search-stage-selection-summary');
  const searchInput = document.querySelector('[data-search-stage-search-input]');
  const tabButtons = document.querySelectorAll('[data-search-stage-tab]');
  const tabContents = document.querySelectorAll('[data-search-stage-tab-content]');
  const noResultsDiv = document.getElementById('search-stage-no-search-results');

  if (!guidField) return;

  // Tab switching
  tabButtons.forEach(button => {
    button.addEventListener('click', function() {
      const targetTab = this.getAttribute('data-search-stage-tab');

      // Update tab buttons
      tabButtons.forEach(btn => btn.classList.remove('active'));
      this.classList.add('active');

      // Update tab content
      tabContents.forEach(content => {
        if (content.getAttribute('data-search-stage-tab-content') === targetTab) {
          content.classList.add('active');
        } else {
          content.classList.remove('active');
        }
      });

      // Reset search when switching tabs
      if (searchInput) {
        searchInput.value = '';
        filterSearchStages('');
      }
    });
  });

  // Stage selection (using event delegation)
  popover.addEventListener('click', function(e) {
    let stageItem = e.target.closest('[data-search-stage-item]');
    if (!stageItem) return;

    const stageGuid = stageItem.getAttribute('data-stage-guid');
    const stageTitle = stageItem.getAttribute('data-stage-title');

    // Update field
    guidField.value = stageGuid;

    // Update summary display
    stageSummary.innerHTML = `
      <span class="stage-selected-badge">
        ${stageTitle} (GUID: ${stageGuid})
        <button type="button" class="stage-clear-button" data-search-stage-clear>×</button>
      </span>
    `;

    // Re-attach clear button listener
    attachSearchClearListener();

    // Close popover
    popover.hidePopover();
  });

  // Clear selection
  function attachSearchClearListener() {
    const clearBtn = document.querySelector('[data-search-stage-clear]');
    if (clearBtn) {
      clearBtn.addEventListener('click', function() {
        guidField.value = '';
        stageSummary.innerHTML = '<span class="text-muted">ステージが選択されていません</span>';
      });
    }
  }
  attachSearchClearListener();

  // Search functionality
  if (searchInput) {
    searchInput.addEventListener('input', function() {
      const keyword = this.value.toLowerCase();
      filterSearchStages(keyword);
    });
  }

  function filterSearchStages(keyword) {
    const activeTabBtn = document.querySelector('[data-search-stage-tab].active');
    let activeTab = 'all'; // default for non-logged in users

    if (activeTabBtn) {
      activeTab = activeTabBtn.getAttribute('data-search-stage-tab');
    }

    const stageItems = document.querySelectorAll(`[data-search-stage-tab-content="${activeTab}"] [data-search-stage-item]`);

    let visibleCount = 0;

    stageItems.forEach(item => {
      const title = item.getAttribute('data-stage-title').toLowerCase();
      const guid = item.getAttribute('data-stage-guid');

      if (title.includes(keyword) || guid.includes(keyword)) {
        item.style.display = '';
        visibleCount++;
      } else {
        item.style.display = 'none';
      }
    });

    // Show/hide no results message
    if (noResultsDiv) {
      if (visibleCount === 0 && keyword !== '') {
        noResultsDiv.style.display = 'block';
      } else {
        noResultsDiv.style.display = 'none';
      }
    }
  }

  // Reset search when popover is opened
  popover.addEventListener('toggle', function(e) {
    if (e.newState === 'open') {
      if (searchInput) {
        searchInput.value = '';
        filterSearchStages('');
      }
    }
  });
}

// Initialize on both turbo:load and DOMContentLoaded
document.addEventListener('turbo:load', initStageSelector);
document.addEventListener('DOMContentLoaded', initStageSelector);
