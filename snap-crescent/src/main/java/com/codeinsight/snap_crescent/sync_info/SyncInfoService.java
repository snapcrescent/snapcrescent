package com.codeinsight.snap_crescent.sync_info;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

public interface SyncInfoService {

	public BaseResponseBean<Long, UiSyncInfo> search(SyncInfoSearchCriteria syncInfoSearchCriteria);

	public void create(SyncInfo syncInfo) throws Exception;

	public void update(SyncInfo syncInfo) throws Exception;

	public UiSyncInfo getById(Long id);

}
