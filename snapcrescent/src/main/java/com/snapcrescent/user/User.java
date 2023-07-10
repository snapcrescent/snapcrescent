package com.snapcrescent.user;

import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.utils.Constant.UserType;

import jakarta.persistence.Basic;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.PostLoad;
import jakarta.persistence.Transient;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class User extends BaseEntity {

	private static final long serialVersionUID = -5417001592780159971L;

	@Column(nullable = false)
	private String firstName;

	private String lastName;

	@Column(unique = true, nullable = false)
	private String username;

	@Column(nullable = false)
	private String password;
	
	@Transient
	private UserType userTypeEnum;
	
	@Basic
	private Integer userType;
	
	@PostLoad
    void fillTransient() {
		
		if(userType > 0) {
			this.userTypeEnum = UserType.findById(userType);
		}
    }

    
    public String getFullName(){
    	return firstName + " " + lastName;
    }

}
