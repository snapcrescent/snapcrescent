package com.snapcrescent.album;


import com.snapcrescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiAlbum extends BaseUiBean {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1540224413175914673L;
	
	private String name;
	private String password;
	private Boolean publicAccess;
	
	private String albumTypeName;
	private int albumType;
	
	private Boolean ownedByMe;
	private Boolean sharedWithOthers;

}
