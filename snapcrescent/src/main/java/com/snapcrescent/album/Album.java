package com.snapcrescent.album;

import java.util.List;

import com.snapcrescent.asset.Asset;
import com.snapcrescent.common.BaseEntity;
import com.snapcrescent.common.utils.Constant.AlbumType;
import com.snapcrescent.config.security.acl.AccessControlQuery;
import com.snapcrescent.user.User;

import jakarta.persistence.Basic;
import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToMany;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PostLoad;
import jakarta.persistence.Transient;
import lombok.Data;
import lombok.EqualsAndHashCode;



@Entity
@Data
@EqualsAndHashCode(callSuper = false)
@AccessControlQuery(
		query="SELECT album.id from Album album " + 
						  "where album.id = :targetEntityId " +
						  "AND album.createdByUserId = :userId"
)
public class Album extends BaseEntity {
	
	private static final long serialVersionUID = -5687399600782387370L;

	private String name;
	private Boolean publicAccess = false;
	
	@Basic
	private Integer albumType;
	
	@Transient
    private AlbumType albumTypeEnum;
	
	
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
	
	@OneToOne(fetch = FetchType.LAZY, cascade = CascadeType.REMOVE, orphanRemoval = true)
	@JoinColumn(name = "PUBLIC_ACCESS_USER_ID", nullable = true, insertable = false, updatable = false)
	private User publicAccessUser;
	
	@Column(name = "PUBLIC_ACCESS_USER_ID", nullable = true, insertable = true, updatable = true)
	private Long publicAccessUserId;
	
	
	@PostLoad
    void fillTransient() {
		if(albumType > 0) {
			this.albumTypeEnum = AlbumType.findById(albumType);
		}	
    }

}
