package com.redhat.example.weather;


import javax.enterprise.context.SessionScoped;
import java.io.Serializable;

@SessionScoped
public class SelectedCountry implements Serializable {

    /**
     * Generated serialVersionUID
     */
    private static final long serialVersionUID = -79144185506126901L;
    
    private String code = "en";


    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }


}
