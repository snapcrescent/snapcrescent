package com.codeinsight.snap_crescent.sync_info;

import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

public interface SyncInfoService {

	public BaseResponseBean<Long, UiSyncInfo> search(SyncInfoSearchCriteria syncInfoSearchCriteria);

	public void save() throws Exception;
	public UiSyncInfo getById(Long id);

}
