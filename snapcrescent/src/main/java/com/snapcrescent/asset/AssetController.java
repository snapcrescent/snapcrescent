package com.snapcrescent.asset;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.UrlResource;
import org.springframework.core.io.support.ResourceRegion;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.snapcrescent.batch.assetImport.AssetImportBatchService;
import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponse;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.ResourceRegionType;

@RestController
public class AssetController extends BaseController {

	@Autowired
	private AssetService assetService;
	
	@Autowired
	private AssetImportBatchService assetImportBatchService;

	@GetMapping("/asset")
	public @ResponseBody BaseResponseBean<Long, UiAsset> search(@RequestParam Map<String, String> searchParams) {
		AssetSearchCriteria searchCriteria = new AssetSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return assetService.search(searchCriteria);

	}

	private void parseSearchParams(Map<String, String> searchParams, AssetSearchCriteria searchCriteria) {

		parseCommonSearchParams(searchParams, searchCriteria);

		if (searchParams.get("assetType") != null) {
			searchCriteria.setAssetType(Integer.parseInt(searchParams.get("assetType")));
		}

		if (searchParams.get("favorite") != null) {
			searchCriteria.setFavorite(Boolean.parseBoolean(searchParams.get("favorite")));
		}
		
		if (searchParams.get("albumId") != null) {
			searchCriteria.setAlbumId(Long.parseLong(searchParams.get("albumId")));
		}
	}

	@GetMapping("/asset/{id}")
	public @ResponseBody BaseResponseBean<Long, UiAsset> get(@PathVariable Long id) {
		BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();
		response.setObjectId(id);
		response.setObject(assetService.getById(id));
		return response;
	}

	@GetMapping(value = "/asset/{token}/stream")
	public ResponseEntity<ResourceRegion> streamAssetById(@PathVariable String token,
			@RequestHeader(value = "Range", required = false) String httpRangeList) throws Exception {
		return getChunkedResponse(token, httpRangeList, ResourceRegionType.STREAM);
	}
	
	@GetMapping(value = "/asset/{token}/download")
	public ResponseEntity<ResourceRegion> downloadAssetById(@PathVariable String token,
			@RequestHeader(value = "Range", required = false) String httpRangeList) throws Exception {
		return getChunkedResponse(token, httpRangeList, ResourceRegionType.DOWNLOAD);
	}

	private ResponseEntity<ResourceRegion> getChunkedResponse(String token, String httpRangeList, ResourceRegionType resourceRegionType) throws Exception {
		
			SecuredAssetStreamDTO assetDetails = assetService.getAssetDetailsFromToken(token);
			
			UrlResource assetFile = new UrlResource("file:" + assetDetails.getFilePath());	
			
			
			AssetType assetType = AssetType.findById(assetDetails.getAssetType());
			
			ResourceRegion region = resourceRegion(assetType, resourceRegionType, assetFile, httpRangeList);

			if (assetType == AssetType.PHOTO) {
				return ResponseEntity.status(HttpStatus.OK)
						.contentType(
								MediaTypeFactory.getMediaType(assetFile).orElse(MediaType.APPLICATION_OCTET_STREAM))
						.body(region);
			} else {
				return ResponseEntity.status(HttpStatus.PARTIAL_CONTENT)
						.contentType(
								MediaTypeFactory.getMediaType(assetFile).orElse(MediaType.APPLICATION_OCTET_STREAM))
						.body(region);
			}
	}

	@PutMapping(value = "/asset/{id}")
	public ResponseEntity<?> update(@PathVariable Long id, @RequestBody UiAsset asset) {
		try {
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PutMapping(value = "/asset/push/favorite")
	public ResponseEntity<?> pushToFavorite(@RequestParam List<Long> ids) {
		try {
			assetService.updateFavoriteFlag(true,ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PutMapping(value = "/asset/pop/favorite")
	public ResponseEntity<?> popFromFavorite(@RequestParam List<Long> ids) {
		try {
			assetService.updateFavoriteFlag(false,ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PostMapping("/asset/upload")
	public ResponseEntity<?> uploadAssets(@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {
			String filesBasePath = assetService.uploadAssets(Arrays.asList(files));
			assetImportBatchService.createBatch(filesBasePath);
			response.setMessage("Asset uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PutMapping(value = "/asset/pop/trash")
	public ResponseEntity<?> popFromInactive(@RequestParam List<Long> ids) {
		try {
			assetService.updateActiveFlag(true,ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@DeleteMapping(value = "/asset/trash")
	public ResponseEntity<?> pushToInactive(@RequestParam List<Long> ids) {
		try {
			assetService.updateActiveFlag(false,ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@DeleteMapping(value = "/asset/permanent")
	public ResponseEntity<?> deletePermanently(@RequestParam List<Long> ids) {
		try {
			assetService.deletePermanently(ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	
	@GetMapping("/asset/timeline")
	public @ResponseBody BaseResponseBean<Long, UiAssetTimeline> getAssetTimeline(@RequestParam Map<String, String> searchParams) {
		BaseResponseBean<Long, UiAssetTimeline> response = new BaseResponseBean<>();
		
		AssetSearchCriteria searchCriteria = new AssetSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		
		response.setObjects(assetService.getAssetTimeline(searchCriteria));
		return response;
	}

}
