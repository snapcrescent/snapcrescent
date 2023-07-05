package com.snapcrescent.album;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponseBean;

@RestController
public class AlbumController extends BaseController{

	@Autowired
	private AlbumService albumService;

	@GetMapping("/album")
	public @ResponseBody BaseResponseBean<Long, UiAlbum> search(@RequestParam Map<String, String> searchParams) {
		AlbumSearchCriteria searchCriteria = new AlbumSearchCriteria();
		parseSearchParams(searchParams, searchCriteria);
		return albumService.search(searchCriteria);

	}
	
	private void parseSearchParams(Map<String, String> searchParams, AlbumSearchCriteria searchCriteria) {
		parseCommonSearchParams(searchParams, searchCriteria);
		
		if (searchParams.get("createdByUserId") != null) {
			searchCriteria.setCreatedByUserId(Long.parseLong(searchParams.get("createdByUserId")));
		}
	}
	
	@PostMapping("/album/asset/assn")
	public @ResponseBody ResponseEntity<?> createAlbumAssetAssociation(@RequestBody UiCreateAlbumAssetAssnRequest createAlbumAssetAssnRequest) {
		albumService.createAlbumAssetAssociation(createAlbumAssetAssnRequest);
		return new ResponseEntity<>(HttpStatus.OK);
	}

	
	
}
