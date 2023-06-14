package com.codeinsight.snap_crescent.asset;


import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class SecuredAssetStreamDTO {
	
	private String filePath;
	private int assetType; 
	private Long validTill;

}
