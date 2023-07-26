package com.snapcrescent.batchProcess.assetImport;


import java.util.List;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiAssetImportBatchProcess extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	private List<Asset> assetEntities;

}
