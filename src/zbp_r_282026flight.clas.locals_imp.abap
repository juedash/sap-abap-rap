CLASS LHC_ZR_282026FLIGHT DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR Flight
        RESULT result,
      validatePrice FOR VALIDATE ON SAVE
            IMPORTING keys FOR Flight~validatePrice,
      validateCurrency FOR VALIDATE ON SAVE
            IMPORTING keys FOR Flight~validateCurrency.
ENDCLASS.

CLASS LHC_ZR_282026FLIGHT IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
  METHOD validatePrice.

  DATA failed_record LIKE LINE OF failed-flight.
  DATA reported_record LIKE LINE OF reported-flight.

  READ ENTITIES OF ZR_282026FLIGHT IN LOCAL MODE
            ENTITY Flight
            FIELDS ( Price )
            WITH CORRESPONDING #( keys )
            RESULT DATA(flights).

  LOOP AT flights INTO DATA(flight).
    IF flight-Price <= 0.
    failed_record-%tky = flight-%tky.
    APPEND failed_record TO failed-flight.
    ELSE.
    reported_record-%tky = flight-%tky.

    reported_record-%msg = new_message(
                                id          = '/LRN/S4D400'
                                number      = '101'
                                severity    =   ms-error ).
    APPEND reported_record TO reported-flight.
    ENDIF.


  ENDLOOP.


  ENDMETHOD.

  METHOD validateCurrency.
  DATA failed_record LIKE LINE OF failed-flight.
  DATA reported_record LIKE LINE OF reported-flight.
  DATA exists TYPE abap_bool.

  READ ENTITIES OF ZR_282026FLIGHT IN LOCAL MODE
    ENTITY Flight
    FIELDS ( CurrencyCode )
    WITH CORRESPONDING #( keys )
    RESULT DATA(flights).

    LOOP AT flights INTO DATA(flight).
        exists = abap_false.

        SELECT SINGLE
            FROM I_CURRENCY
            FIELDS @abap_true
            WHERE Currency = @flight-CurrencyCode
            INTO @exists.
    ENDLOOP.
    IF exists = abap_false.
        failed_record-%tky = flight-%tky.
        APPEND failed_record TO failed-flight.
    ELSE.
        reported_record-%tky = flight-%tky.
        reported_record-%msg = new_message(
                                 id = '/LRN/S4D400'
                                 number = '102'
                                 severity = if_abap_behv_message=>severity-error
                                 v1 = flight-currencycode
                                 ).
        APPEND reported_record TO reported-flight.
    ENDIF.



  ENDMETHOD.

ENDCLASS.
