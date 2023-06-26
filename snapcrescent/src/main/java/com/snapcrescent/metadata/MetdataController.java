package com.snapcrescent.metadata;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponseBean;

@RestController
public class MetdataController extends BaseController {

	@Autowired
	private MetadataService metadataService;

	@GetMapping("/metadata/timeline")
	public @ResponseBody BaseResponseBean<Long, UiMetadataTimeline> getMetadataTimeline() {
		BaseResponseBean<Long, UiMetadataTimeline> response = new BaseResponseBean<>();
		response.setObjects(metadataService.getMetadataTimeline());
		return response;
	}
}
