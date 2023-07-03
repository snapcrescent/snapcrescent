package com.snapcrescent.album;

import java.util.List;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.user.User;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import lombok.Data;
import lombok.EqualsAndHashCode;



@Entity
@Data
@EqualsAndHashCode(callSuper = false)
public class Album extends BaseEntity {
	
	private static final long serialVersionUID = -5687399600782387370L;

	private String name;
	private String password;
	private Boolean publicAccess = false;
	
	
	@ManyToMany(fetch = FetchType.LAZY, cascade = CascadeType.DETACH)
	@JoinTable(name = "ALBUM_USER_ASSN", joinColumns = {
			@JoinColumn(name = "ALBUM_ID", updatable = false) }, inverseJoinColumns = {
					@JoinColumn(name = "USER_ID", updatable = false) })
	private List<User> users;
	
	@ManyToMany(fetch = FetchType.LAZY, cascade = CascadeType.DETACH)
	@JoinTable(name = "ALBUM_ASSET_ASSN", joinColumns = {
			@JoinColumn(name = "ALBUM_ID", updatable = false) }, inverseJoinColumns = {
					@JoinColumn(name = "ASSET_ID", updatable = false) })
	private List<Asset> assets;

}
