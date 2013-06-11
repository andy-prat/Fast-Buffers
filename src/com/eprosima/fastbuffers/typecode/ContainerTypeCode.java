package com.eprosima.fastbuffers.typecode;

public abstract class ContainerTypeCode extends TypeCode
{
    protected ContainerTypeCode(int kind)
    {
        super(kind);
    }
    
    @Override
    public abstract String getTypename();
    
    public TypeCode getContentTypeCode()
    {
        return m_contentTypeCode;
    }
    
    public void setContentTypeCode(TypeCode contentTypeCode)
    {
        m_contentTypeCode = contentTypeCode;
    }
    
    private TypeCode m_contentTypeCode = null;
}