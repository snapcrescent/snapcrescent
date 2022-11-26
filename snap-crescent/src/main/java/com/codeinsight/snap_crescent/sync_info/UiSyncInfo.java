package com.codeinsight.snap_crescent.sync_info;

import java.util.Date;

import com.codeinsight.snap_crescent.common.beans.BaseUiBean;
import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiSyncInfo extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date creationDateTime;

	@JsonFormat(shape = JsonFormat.Shape.NUMBER)
	private Date lastModifiedDateTime;
}
