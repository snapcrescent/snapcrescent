package com.snapcrescent.asset;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class SecuredAssetStreamDTO {
	
	private String filePath;
	private Integer assetType; 
	private Long validTill;

}