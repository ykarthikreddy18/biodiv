package species.auth

import org.springframework.security.web.authentication.logout.LogoutHandler
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.springframework.security.core.Authentication
import javax.servlet.http.Cookie
import org.apache.log4j.Logger

import species.utils.Utils;

class FacebookAuthCookieLogoutHandler implements LogoutHandler {

	private static final Logger logger = Logger.getLogger(this)

	FacebookAuthUtils facebookAuthUtils

	void logout(HttpServletRequest httpServletRequest,
	HttpServletResponse httpServletResponse,
	Authentication authentication) {
		facebookAuthUtils.logout(httpServletRequest, httpServletResponse);
	}

	
}
