package com.codeinsight.snap_crescent.sync_info;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.codeinsight.snap_crescent.common.BaseController;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

@RestController
public class SyncInfoController extends BaseController {

	@Autowired
	private SyncInfoService syncInfoService;
	
	@GetMapping("/sync-info")
	public @ResponseBody BaseResponseBean<Long, UiSyncInfo> search(@RequestParam Map<String, String> searchParams) {
		SyncInfoSearchCriteria searchCriteria = new SyncInfoSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return syncInfoService.search(searchCriteria);
		
	}

	private void parseSearchParams(Map<String, String> searchParams, SyncInfoSearchCriteria searchCriteria) {
		
		parseCommonSearchParams(searchParams, searchCriteria);

		
	}
	
	@GetMapping("/sync-info/{id}")
	public  @ResponseBody BaseResponseBean<Long, UiSyncInfo> get(@PathVariable Long id) {
			BaseResponseBean<Long, UiSyncInfo> response = new BaseResponseBean<>();	
			response.setObjectId(id);
			response.setObject(syncInfoService.getById(id));
			return response;
	}
}
