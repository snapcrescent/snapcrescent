package com.codeinsight.snap_crescent.asset;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.BaseController;
import com.codeinsight.snap_crescent.common.beans.BaseResponse;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.ASSET_TYPE;
import com.codeinsight.snap_crescent.sync_info.SyncInfoService;

@RestController
public class AssetController extends BaseController{

	@Autowired
	private AssetService assetService;
	
	@Autowired
	private SyncInfoService syncInfoService;

	@GetMapping("/asset")
	public @ResponseBody BaseResponseBean<Long, UiAsset> search(@RequestParam Map<String, String> searchParams) {
		AssetSearchCriteria searchCriteria = new AssetSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return assetService.search(searchCriteria);
		
	}

	private void parseSearchParams(Map<String, String> searchParams, AssetSearchCriteria searchCriteria) {
		
		parseCommonSearchParams(searchParams, searchCriteria);
		
		if (searchParams.get("assetType") != null) {
			searchCriteria.setAssetType(ASSET_TYPE.findByValue(Integer.parseInt(searchParams.get("assetType"))));
		}

		if (searchParams.get("favorite") != null) {
			searchCriteria.setFavorite(Boolean.parseBoolean(searchParams.get("favorite")));
		}
		
		if (searchParams.get("month") != null) {
			searchCriteria.setMonth(searchParams.get("month"));
		}
		
		if (searchParams.get("year") != null) {
			searchCriteria.setYear(searchParams.get("year"));
		}
	}
	
	@GetMapping("/asset/{id}")
	public  @ResponseBody BaseResponseBean<Long, UiAsset> get(@PathVariable Long id) {
			BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();	
			response.setObjectId(id);
			response.setObject(assetService.getById(id));
			return response;
	}
	
	@GetMapping(value="/asset/{id}/raw", produces = MediaType.IMAGE_JPEG_VALUE)
	public ResponseEntity<byte[]> getAssetById(@PathVariable Long id) {
		try {
			return new ResponseEntity<>(assetService.getAssetById(id), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PutMapping(value="/asset/{id}")
	public ResponseEntity<?> update(@PathVariable Long id, @RequestBody UiAsset asset) {
		try {
			// assetService.like(id);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PostMapping("/asset/upload")
	public ResponseEntity<?> uploadImage(@RequestParam("assetType") int assetType,@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {
			
			ASSET_TYPE assetTypeEnum =  ASSET_TYPE.findByValue(assetType);
			List<File> temporaryFiles = assetService.uploadAssets(assetTypeEnum, Arrays.asList(files));	
			
			List<Future<Boolean>> processingStatusList = new ArrayList<>(temporaryFiles.size());
			for (File temporaryFile : temporaryFiles) {
				processingStatusList.add(assetService.processAsset(assetTypeEnum, temporaryFile));
			}
			
			// wait for all threads
			processingStatusList.forEach(result -> {
			    try {
			      result.get();
			    } catch (Exception e) {
			      
			    }
			  });
			
			if(temporaryFiles.size() > 0) {
				syncInfoService.creatOrUpdate();
			}
			
			response.setMessage("Asset uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
