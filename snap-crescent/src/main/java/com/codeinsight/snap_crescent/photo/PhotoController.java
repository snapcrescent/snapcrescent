package com.codeinsight.snap_crescent.photo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.codeinsight.snap_crescent.common.BaseController;
import com.codeinsight.snap_crescent.common.beans.BaseResponse;
import com.codeinsight.snap_crescent.common.beans.BaseResponseBean;

@RestController
public class PhotoController extends BaseController{

	@Autowired
	private PhotoService photoService;

	@GetMapping("/photo")
	public @ResponseBody BaseResponseBean<Long, UiPhoto> search(@RequestParam Map<String, String> searchParams) {
		PhotoSearchCriteria searchCriteria = new PhotoSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return photoService.search(searchCriteria);
		
	}

	private void parseSearchParams(Map<String, String> searchParams, PhotoSearchCriteria searchCriteria) {
		
		parseCommonSearchParams(searchParams, searchCriteria);

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
	
	@GetMapping("/photo/{id}")
	public  @ResponseBody BaseResponseBean<Long, UiPhoto> get(@PathVariable Long id) {
			BaseResponseBean<Long, UiPhoto> response = new BaseResponseBean<>();	
			response.setObjectId(id);
			response.setObject(photoService.getById(id));
			return response;
	}
	
	@GetMapping(value="/photo/{id}/image", produces = MediaType.IMAGE_JPEG_VALUE)
	public ResponseEntity<byte[]> getImageById(@PathVariable Long id) {
		try {
			return new ResponseEntity<>(photoService.getImageById(id), HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}
	
	@PostMapping(value="/photo/{id}/like")
	public ResponseEntity<?> like(@PathVariable Long id) {
		try {
			photoService.like(id);
			return new ResponseEntity<>(HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
	}

	@PostMapping("/photo/upload")
	public ResponseEntity<?> uplaodImage(@RequestParam("files") MultipartFile[] files) throws IOException {

		BaseResponse response = new BaseResponse();
		try {
			photoService.upload(new ArrayList<MultipartFile>(Arrays.asList(files)));
			response.setMessage("Image uploaded successfully.");
			return new ResponseEntity<>(response, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			response.setMessage(e.getMessage());
		}
		return new ResponseEntity<>(response, HttpStatus.INTERNAL_SERVER_ERROR);
	}
}
