package com.snapcrescent.album;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import com.snapcrescent.common.BaseController;
import com.snapcrescent.common.beans.BaseResponseBean;
import com.snapcrescent.config.security.acl.AuthorizeURL;
import com.snapcrescent.user.UiUser;

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
	
	
	@GetMapping("/album/{id}")
	@AuthorizeURL(targetEntity = Album.class)
	public @ResponseBody BaseResponseBean<Long, UiAlbum> get(@PathVariable Long id) {
		BaseResponseBean<Long, UiAlbum> response = new BaseResponseBean<>();

		try {
			response.setObjectId(id);
			response.setObject(albumService.getById(id));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
	
	@GetMapping("/album/{id}/lite")
	public @ResponseBody BaseResponseBean<Long, UiAlbum> getLite(@PathVariable Long id) {
		BaseResponseBean<Long, UiAlbum> response = new BaseResponseBean<>();

		try {
			response.setObjectId(id);
			response.setObject(albumService.getLiteById(id));
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
	
	@PutMapping(value = "/album/{id}")
	@AuthorizeURL(targetEntity = Album.class)
	public @ResponseBody BaseResponseBean<Long, UiAlbum> update(@PathVariable Long id, @RequestBody UiAlbum album) {
		BaseResponseBean<Long, UiAlbum> response = new BaseResponseBean<>();

		try {
			album.setId(id);
			albumService.update(album);

			response.setObjectId(id);
			response.setObject(album);

		} catch (Exception e) {
			e.printStackTrace();
			response.setSuccess(false);
		}
		return response;

	}
	
	@DeleteMapping(value = "/album/{id}")
	@AuthorizeURL(targetEntity = Album.class)
	public BaseResponseBean<Long, UiUser> delete(@PathVariable Long id) {
		BaseResponseBean<Long, UiUser> response = new BaseResponseBean<>();

		try {
			albumService.delete(id);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return response;
	}
	
	@PostMapping("/album/asset/assn")
	public @ResponseBody ResponseEntity<?> createAlbumAssetAssociation(@RequestBody UiCreateAlbumAssetAssnRequest createAlbumAssetAssnRequest) {
		albumService.createAlbumAssetAssociation(createAlbumAssetAssnRequest);
		return new ResponseEntity<>(HttpStatus.OK);
	}
		
}
