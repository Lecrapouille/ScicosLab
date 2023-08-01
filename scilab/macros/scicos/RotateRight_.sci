function RotateRight_()
// Copyright INRIA
//** Al@n

    scs_m_save = scs_m ;
    nc_save    = needcompile ;
    [scs_m] = do_turn(%pt,scs_m,-45)

    Cmenu=[];
    %pt = [];
endfunction
