package egovframework.govportal.security;

import egovframework.govportal.rbac.dao.RbacDAO;
import egovframework.govportal.rbac.model.UserVO;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service("egovUserDetailsService")
public class EgovUserDetailsService implements UserDetailsService {

    @Resource(name = "rbacDAO")
    private RbacDAO rbacDAO;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        UserVO user = rbacDAO.selectUserByUsername(username);
        if (user == null) {
            throw new UsernameNotFoundException("사용자를 찾을 수 없습니다: " + username);
        }

        UUID userId = user.getId();
        List<String> roleCodes = rbacDAO.selectRoleCodesByUser(userId);
        List<String> permissionCodes = rbacDAO.selectPermissionCodesByUser(userId);

        List<GrantedAuthority> authorities = new ArrayList<>();
        authorities.add(new SimpleGrantedAuthority("ROLE_USER"));
        for (String roleCode : roleCodes) {
            if (!roleCode.startsWith("ROLE_")) {
                authorities.add(new SimpleGrantedAuthority(roleCode));
            } else {
                authorities.add(new SimpleGrantedAuthority(roleCode));
            }
        }
        authorities.add(new SimpleGrantedAuthority("GRADE_" + user.getGrade()));
        for (String perm : permissionCodes) {
            authorities.add(new SimpleGrantedAuthority("PERM_" + perm));
        }

        return new GovportalUserDetails(userId, user.getUsername(), user.getPassword(), authorities);
    }
}
