package com.snapcrescent.user;


import com.snapcrescent.common.beans.BaseUiBean;

import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = false)
public class UiUser extends BaseUiBean {
	/**
	* 
	*/
	private static final long serialVersionUID = -873185495294499014L;
	
	private String firstName;
	private String lastName;
	
	private String username;
	private String password;
	
	private String userTypeName;
	private Integer userType;
	
	public String getFullName(){
    	return firstName + " " + lastName;
    }

}
