package com.redhat.example.weather;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;

@RequestScoped
@Path("country")
public class CountryService {
    @Inject
    SelectedCountry selectedCountry;

    @PUT
    @Path("/{code}")
    public void setSelectedCountry(@PathParam("code") String countryCode) {
        selectedCountry.setCode(countryCode);
    }
}
