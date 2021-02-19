package com.redhat.example.weather;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
//import org.eclipse.microprofile.opentracing.Traced;

@RequestScoped
@Path("weather")
//@Traced
public class WeatherService {


    @Inject
    SelectedCountry selectedCountry;

    @PersistenceContext(unitName = "primary")
    EntityManager em;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Country getList() {
        return em.find(Country.class,selectedCountry.getCode());
    }

}
