package com.codeinsight.snap_crescent.user;

import java.util.List;

import javax.persistence.TypedQuery;

import org.springframework.stereotype.Repository;

import com.codeinsight.snap_crescent.common.BaseRepository;

@Repository
public class UserRepository extends BaseRepository<User> {

	public UserRepository() {
		super(User.class);
	}

	public User findByUsername(String username) {
		String query = "SELECT user FROM User user WHERE user.username = :username";
		
		TypedQuery<User> typedQuery = getCurrentSession().createQuery(query,User.class);
		typedQuery.setParameter("username", username);
		List<User> results = typedQuery.getResultList();
		return results.isEmpty() ? null : results.get(0);
	}

	public boolean existsByUsername(String username) {
		// TODO Auto-generated method stub
		return false;
	}

	public int count() {
		// TODO Auto-generated method stub
		return 0;
	}

	/*
	 * @RestResource(exported = false) public boolean
	 * existsByUsername(@Param("username") String username);
	 * 
	 * @RestResource(exported = false) public Optional<User>
	 * findByUsernameAndPassword(@Param("username") String
	 * username,@Param("password") String password);
	 * 
	 * @RestResource(exported = false) public Optional<User>
	 * findByUsername(@Param("username") String username);
	 */

}
