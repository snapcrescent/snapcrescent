package com.snapcrescent.thumbnail;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.UrlResource;
import org.springframework.core.io.support.ResourceRegion;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.MediaTypeFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.ResourceRegionType;

@RestController
public class ThumbnailController extends BaseController{

	@Autowired
	private ThumbnailService thumbnailService;

	@GetMapping(value = "/thumbnail/{id}", produces = MediaType.IMAGE_JPEG_VALUE)
	public ResponseEntity<ResourceRegion> streamThumbnailById(@PathVariable Long id,@RequestHeader(value = "Range", required = false) String httpRangeList ) {
		try {
			
			UrlResource thumnailFile = new UrlResource("file:"+thumbnailService.getFilePathByThumbnailById(id));
			
			ResourceRegion region = resourceRegion(AssetType.PHOTO,ResourceRegionType.STREAM, thumnailFile, httpRangeList);
			
			return ResponseEntity.status(HttpStatus.OK)
	                .contentType(MediaTypeFactory.getMediaType(thumnailFile).orElse(MediaType.APPLICATION_OCTET_STREAM))
	                .body(region);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@GetMapping(value = "/thumbnail/{token}/stream", produces = MediaType.IMAGE_JPEG_VALUE)
	public ResponseEntity<ResourceRegion> streamThumbnailByToken(@PathVariable String token,@RequestHeader(value = "Range", required = false) String httpRangeList ) {
		try {
			
			SecuredAssetStreamDTO assetDetails = thumbnailService.getAssetDetailsFromToken(token);
			
			UrlResource thumnailFile = new UrlResource("file:" + assetDetails.getFilePath());	
			
			ResourceRegion region = resourceRegion(AssetType.PHOTO,ResourceRegionType.STREAM, thumnailFile, httpRangeList);
			
			return ResponseEntity.status(HttpStatus.OK)
	                .contentType(MediaTypeFactory.getMediaType(thumnailFile).orElse(MediaType.APPLICATION_OCTET_STREAM))
	                .body(region);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

}
