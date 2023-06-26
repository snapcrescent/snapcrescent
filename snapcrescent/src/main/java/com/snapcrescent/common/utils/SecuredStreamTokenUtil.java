package com.snapcrescent.common.utils;

import java.util.Calendar;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.core.type.TypeReference;
import com.snapcrescent.asset.Asset;
import com.snapcrescent.asset.SecuredAssetStreamDTO;
import com.snapcrescent.common.utils.Constant.AssetType;
import com.snapcrescent.common.utils.Constant.FILE_TYPE;
import com.snapcrescent.thumbnail.Thumbnail;

@Component
public class SecuredStreamTokenUtil {
	
	@Autowired
	private FileService fileService;
	
	
	public String getSignedAssetStreamToken(Thumbnail thumbnail) {
		String filePath = fileService.getFile(FILE_TYPE.THUMBNAIL, thumbnail.getPath(), thumbnail.getName()).getAbsolutePath();
		return generateToken(null, filePath);
		
	}

	public String getSignedAssetStreamToken(Asset asset) {
		
		FILE_TYPE fileType = null;
		
		if (asset.getAssetType() == AssetType.PHOTO.getId()) {
			fileType = FILE_TYPE.PHOTO;
		}

		if (asset.getAssetType() == AssetType.VIDEO.getId()) {
			fileType = FILE_TYPE.VIDEO;
		}
		
		String filePath = fileService .getFile(fileType, asset.getMetadata().getPath(), asset.getMetadata().getInternalName()).getAbsolutePath();

		return generateToken(asset.getAssetType(), filePath);
	}
	
	private String generateToken(Integer assetType, String filePath) {
		
		int tokenAge = 30 * 60; // 30 Minutes
	
		SecuredAssetStreamDTO tokenPayload = new SecuredAssetStreamDTO();

		Calendar validTill = Calendar.getInstance();
		validTill.add(Calendar.SECOND, tokenAge);

		tokenPayload.setFilePath(filePath);
		tokenPayload.setAssetType(assetType);
		tokenPayload.setValidTill(validTill.getTimeInMillis());

		String encryptedToken = null;

		try {
			String tokenPayloadJson = JsonUtils.writeJsonString(tokenPayload);
			encryptedToken = StringEncrypter.encrypt(tokenPayloadJson);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return encryptedToken;
	}

	public SecuredAssetStreamDTO getAssetDetailsFromToken(String encryptedToken) throws Exception {

		String tokenPayloadJson = StringEncrypter.decrypt(encryptedToken);
		SecuredAssetStreamDTO tokenPayload = JsonUtils.getObjectFromJson(tokenPayloadJson,
				new TypeReference<SecuredAssetStreamDTO>() {
				});

		Calendar currentTime = Calendar.getInstance();

		if (tokenPayload.getValidTill() > currentTime.getTimeInMillis()) {
			return tokenPayload;
		} else {
			throw new AuthenticationServiceException("Invalid URL");
		}
	}

}
