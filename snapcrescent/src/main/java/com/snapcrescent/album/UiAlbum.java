package com.snapcrescent.album;


import java.util.List;

import com.snapcrescent.common.beans.BaseUiBean;
import com.snapcrescent.thumbnail.UiThumbnail;
import com.snapcrescent.user.UiUser;

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
	private Boolean publicAccess;
	
	private String albumTypeName;
	private int albumType;
	
	private Boolean ownedByMe;
	private Boolean sharedWithOthers;
	
	private UiThumbnail albumThumbnailObject;
	private Long albumThumbnailId;
	
	private List<UiUser> users;
	
	//Intentionally named different to control mapping via Modelmap
	private UiUser publicAccessUserObject;

	//Transient
	private String newPassword;
}
