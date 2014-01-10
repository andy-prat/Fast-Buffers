/*************************************************************************
 * Copyright (c) 2013 eProsima. All rights reserved.
 *
 * This copy of FastBuffers is licensed to you under the terms described in the
 * FAST_BUFFERS_LICENSE file included in this distribution.
 *
 *************************************************************************/

package com.eprosima.fastbuffers.typecode;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.antlr.stringtemplate.language.DefaultTemplateLexer;

import com.eprosima.fastbuffers.templates.TemplateUtil;
import com.eprosima.fastbuffers.util.Pair;

public abstract class TypeCode
{
    public static final int KIND_NULL = 0x00000000;
    public static final int KIND_SHORT = 0x00000001;
    public static final int KIND_LONG = 0x00000002;
    public static final int KIND_USHORT = 0x00000003;
    public static final int KIND_ULONG = 0x00000004;
    public static final int KIND_FLOAT = 0x00000005;
    public static final int KIND_DOUBLE = 0x00000006;
    public static final int KIND_BOOLEAN = 0x00000007;
    public static final int KIND_CHAR = 0x00000008;
    public static final int KIND_OCTET = 0x00000009;
    public static final int KIND_STRUCT = 0x0000000a;
    public static final int KIND_UNION = 0x0000000b;
    public static final int KIND_ENUM = 0x0000000c;
    public static final int KIND_STRING = 0x0000000d;
    public static final int KIND_SEQUENCE = 0x0000000e;
    public static final int KIND_ARRAY = 0x0000000f;
    public static final int KIND_ALIAS = 0x00000010;
    public static final int KIND_LONGLONG = 0x00000011;
    public static final int KIND_ULONGLONG = 0x00000012;
    public static final int KIND_LONGDOUBLE = 0x00000013;
    public static final int KIND_WCHAR = 0x00000014;
    public static final int KIND_WSTRING = 0x00000015;
    public static final int KIND_VALUE = 0x00000016;
    public static final int KIND_SPARSE = 0x00000017;
    
    protected static StringTemplateGroup m_typesgr = StringTemplateGroup.loadGroup("Types", DefaultTemplateLexer.class, null);
    
    public TypeCode(int kind)
    {
        m_kind = kind;
    }
    
    public int getKind()
    {
        return m_kind;
    }
    
    public abstract String getTypename();
   
    
    protected StringTemplate getStringTemplate()
    {
        return m_typesgr.getInstanceOf("type_" + Integer.toHexString(m_kind));
    }
    
    /*!
     * @brief This function returns the type as a string: "type_2", where the number is the type kind.
     * This function is used in stringtemplates.
     */
    public String getStType()
    {
        return "type_" + Integer.toHexString(m_kind);
    }
    
    // Function used in stringtemplates
    public String getStriptypename()
    {
        return TemplateUtil.stripType(getTypename());
    }
    
    // By default a typecode is not primitive. Function used in stringtemplates
    public boolean isPrimitive()
    {
        return false;
    }
    
    // By default a typecode doesn't have a max size limit. Function used in stringtemplates
    public String getMaxsize()
    {
        return null;
    }
    
    protected int getSize()
    {
        return 0;
    }
    
    public abstract Pair<Integer, Integer> getMaxSerializedSize(int currentSize, int lastDataAligned);
    
    public abstract int getMaxSerializedSizeWithoutAlignment(int currentSize);
    
    private int m_kind = KIND_NULL;
}
