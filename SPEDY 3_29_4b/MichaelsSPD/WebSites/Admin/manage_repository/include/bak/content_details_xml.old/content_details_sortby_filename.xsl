<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes" cdata-section-elements="Topic_Name Topic_NavName Topic_Summary script style"/>
	<xsl:template match="/">
		<content>
			<xsl:for-each select="content/item">
				<xsl:sort select="Topic_Name" data-type="text"/>
				<xsl:copy>
					<xsl:apply-templates select="*"/>
				</xsl:copy>
			</xsl:for-each>
		</content>
	</xsl:template>
</xsl:stylesheet>