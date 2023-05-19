package com.codeinsight.snap_crescent.asset;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;

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

import com.codeinsight.snap_crescent.common.BaseController;
import com.codeinsight.snap_crescent.common.beans.BaseResponse;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;
import com.codeinsight.snap_crescent.common.utils.Constant.AssetType;
import com.codeinsight.snap_crescent.common.utils.Constant.ResourceRegionType;

@RestController
public class AssetController extends BaseController {

	@Autowired
	private AssetService assetService;

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
	}

	@GetMapping("/asset/{id}")
	public @ResponseBody BaseResponseBean<Long, UiAsset> get(@PathVariable Long id) {
		BaseResponseBean<Long, UiAsset> response = new BaseResponseBean<>();
		response.setObjectId(id);
		response.setObject(assetService.getById(id));
		return response;
	}

	@GetMapping(value = "/asset/{id}/raw")
	public ResponseEntity<byte[]> getAssetById(@PathVariable Long id) {
		try {
			return new ResponseEntity<>(assetService.getAssetById(id), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@GetMapping(value = "/asset/{id}/stream")
	public ResponseEntity<ResourceRegion> streamAssetById(@PathVariable Long id,
			@RequestHeader(value = "Range", required = false) String httpRangeList) {
		return getChunkedResponse(id, httpRangeList, ResourceRegionType.STREAM);
	}

	@GetMapping(value = "/asset/{id}/download")
	public ResponseEntity<ResourceRegion> downloadAssetById(@PathVariable Long id,
			@RequestHeader(value = "Range", required = false) String httpRangeList) {
		return getChunkedResponse(id, httpRangeList, ResourceRegionType.DOWNLOAD);
	}

	private ResponseEntity<ResourceRegion> getChunkedResponse(Long id, String httpRangeList, ResourceRegionType resourceRegionType) {
		try {
			UiAsset asset = assetService.getById(id);
			UrlResource assetFile = new UrlResource("file:" + assetService.getFilePathByAssetById(id));

			AssetType assetType = AssetType.findById(asset.getAssetType());

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

		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PutMapping(value = "/asset/{id}/metadata")
	public ResponseEntity<?> updateMetadata(@PathVariable Long id) {
		try {
			assetService.updateMetadata(id);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
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

	@PostMapping("/asset/upload")
	public ResponseEntity<?> uploadAssets(@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {

			List<File> temporaryFiles = assetService.uploadAssets(Arrays.asList(files));

			List<Future<Boolean>> processingStatusList = new ArrayList<>(temporaryFiles.size());
			for (File temporaryFile : temporaryFiles) {
				processingStatusList.add(assetService.processAsset(temporaryFile));
			}

			// wait for all threads
			processingStatusList.forEach(result -> {
				try {
					result.get();
				} catch (Exception e) {

				}
			});

			response.setMessage("Asset uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PutMapping(value = "/asset/restore")
	public ResponseEntity<?> restore(@RequestParam List<Long> ids) {
		try {
			assetService.markActive(ids);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@DeleteMapping(value = "/asset")
	public ResponseEntity<?> delete(@RequestParam List<Long> ids) {
		try {
			assetService.markInactive(ids);
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

}
