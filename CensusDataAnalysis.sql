

----------------------------------------------------------------------------------------------------------------
------------------------Creating a database name as housing project--------------------------------------
CREATE DATABASE CensusProject;

-----------------------------Opening housing project-------------------------------------------------
USE CensusProject;

-------------------------imported the data from a csv file---------------------------------------------

---------------------------checking the data in the table----------------------------------------------------

select *
from dbo.CensusIndia1;

select *
from dbo.CensusIndia2;

select replace(Area_km2,',',''), replace(Population,',','')
from dbo.CensusIndia2;

ALTER TABLE dbo.CensusIndia2
ADD Area_Km int, PopulationCount int;

UPDATE dbo.CensusIndia2 
Set Area_Km = replace(Area_km2,',','') ,
PopulationCount = replace(Population,',','') from dbo.CensusIndia2;

ALTER TABLE dbo.CensusIndia2
DROP COLUMN Area_km2,Population;



-------------------------------------------------------------------------------
---------- calculated number of rows---------------

select COUNT(*) as TotalRows
from dbo.CensusIndia1;
select COUNT(*) as TotalRows
from dbo.CensusIndia2;



---------------------------------------------------------------------------------
----------Get Data from particular states--------------------------------------
select distinct state
from dbo.CensusIndia1;

select *
from dbo.CensusIndia1
where state IN ('Andhra Pradesh','Goa' );

----------------------------------------------------------------------------------
----calculated TotalPopulation of India------------------------------------------

select sum(PopulationCount) as IndiaPopulation
from dbo.CensusIndia2;



------------------------------------
----calculated Average Growth of India----------

Select CONCAT(ROUND(AVG(CAST(Replace(Growth,'%','') as float)),2),'%') as AverageGrowth
from dbo.CensusIndia1;


----------------------------------------------------------------------------------------------------
-----------calculate average growth for each state-------------------------------------------------

select State, CONCAT(ROUND(AVG(CAST(Replace(Growth,'%','') as float)),2),'%') as AverageGrowthRate
from dbo.CensusIndia1
group by State;



------------------------------------------------------------------------------------------------------------
----------calculated average sex ratio per each state----------------------------------------------------

select State, avg(Sex_Ratio) as AverageSexRatio
from dbo.CensusIndia1
group by State
Order By AverageSexRatio DESC;

-----------------------------------------------------------------------------------------------------------------
---------------------Calculated average literacy rate and get state with more than or equal to 75--------------


select *
from dbo.CensusIndia1

select State, ROUND(avg(Literacy),2) as AverageLiteracy
from dbo.CensusIndia1
group by State
having ROUND(avg(Literacy),2) >= 75
Order By AverageLiteracy DESC;



-----------------------------------------------------------------------------------------
-----------Calculated TOP 3 states with highest average growth rate--------------------------

select top 3
    State, CONCAT(ROUND(AVG(CAST(Replace(Growth,'%','') as float)),2),'%') as AverageGrowthRate
from dbo.CensusIndia1
group by State
order by AverageGrowthRate desc;


--------------------------------------------------------------------------------------------
---------------Bottom 3 states with average growthrate--------------

select top 3
    State, CONCAT(ROUND(AVG(CAST(Replace(Growth,'%','') as float)),2),'%') as AverageGrowthRate
from dbo.CensusIndia1
group by State
order by AverageGrowthRate asc;

--------------------------------------------------------------------------------------------
-------------------------------Top 3 and bottom 3 states in Literacy-------------------------

--------using temporary Table --------------
drop table if exists #TopStates;

CREATE Table #TopStates
(
    state nvarchar(50)
,
    topstate float
);

insert into  #TopStates
select State, ROUND(avg(Literacy),2) as AverageLiteracy
from dbo.CensusIndia1
group by State
Order By AverageLiteracy DESC;

select *
from #TopStates;

    select *
    from(
select top 3
            *, 'TOP 3 STATES' as TopBottom
        from #TopSTates
        order by topstate desc) a
UNION
    select *
    from (
select top 3
            * , 'BOTTOM 3 STATES' as TopBottom
        from #TopSTates
        order by topstate asc) b;

-----------Using CTE--------------

WITH
    CTE_AVGLIT
    AS
    (
        select State, ROUND(avg(Literacy),2) as AverageLiteracy
        from dbo.CensusIndia1
        group by State
    )
    select *
    from(
select top 3
            *, 'TOP 3 STATES' as TopBottom
        from CTE_AVGLIT
        order by AverageLiteracy desc) a
UNION
    select *
    from (
select top 3
            * , 'BOTTOM 3 STATES' as TopBottom
        from CTE_AVGLIT
        order by AverageLiteracy asc) b;

-----------------------------------------------------------------
-----------State starting with letter 'T'---------


select distinct State
from dbo.CensusIndia1
where UPPER(State) LIKE 'T%';

-----------States Starting with m or l--------------------

select distinct State
from dbo.CensusIndia1
where UPPER(State) LIKE 'M%' or UPPER(State) LIKE 'L%';

-----------States Starting with a and ending with h----------

select distinct State
from dbo.CensusIndia1
where UPPER(State) LIKE 'A%H';

------OR-----
select distinct State
from dbo.CensusIndia1
where UPPER(State) LIKE 'A%' AND UPPER(State) LIKE '%H';

--------------------------------------------------------------
------Calcualte Males and females population count------------


select h.district, h.state, round(h.PopulationCount/(h.sex_ratio+1),0) as males, round((h.PopulationCount * h.sex_ratio)/(h.sex_ratio+1),0) as Females
from
    (select a.district, a.state, a.sex_ratio/1000 as Sex_ratio, b.PopulationCount
    from dbo.CensusIndia1 a inner join dbo.CensusIndia2 b on a.district = b.district) h

select x.state, SUM(males) as StateMales, SUM(Females) as StateFemales
from
    (select h.district, h.state, round(h.PopulationCount/(h.sex_ratio+1),0) as males, round((h.PopulationCount * h.sex_ratio)/(h.sex_ratio+1),0) as Females
    from
        (select a.district, a.state, a.sex_ratio/1000 as Sex_ratio, b.PopulationCount
        from dbo.CensusIndia1 a inner join dbo.CensusIndia2 b on a.district = b.district) h) x
GROUP BY x.state
ORDER BY x.state;


------------------------------------------------------------------------------
-------------- Literated and Iiliterated People count of each state -------------------------------------------



select x.state, SUM(LiteracyCount) as StateLiteracyCount, SUM(IiliterateCount) as StateIiliteracyCount
from
    (select h.State, h.District, ROUND((h.Literacy * h.PopulationCount),0) as LiteracyCount, ROUND(((1-h.Literacy)* h.PopulationCount),0) as IiliterateCount
    from
        (select a.district, a.state, a.literacy/100 as Literacy, b.PopulationCount
        from dbo.CensusIndia1 a inner join dbo.CensusIndia2 b on a.district = b.district) h)x
GROUP BY x.state
ORDER BY x.state;


--------------------------------------------------------------------------------------
---------------------Population count in Previous Census-----------------------------------------------



select SUM(PreviousCensusPopulation) as StatePreviousCensusPopulation, SUM(CurrentCensusdata) as StateCurrentCensusdata
from
    (select h.State, h.District, ROUND((h.PopulationCount/(1+(h.Growth/100))),0) as PreviousCensusPopulation, h.PopulationCount as CurrentCensusdata
    from
        (select a.district, a.state, CAST(Replace(a.Growth,'%','') as float) as Growth, b.PopulationCount
        from dbo.CensusIndia1 a inner join dbo.CensusIndia2 b on a.district = b.district) h) x;
/*GROUP BY x.state
ORDER BY x.state*/

--------------------------------------------------------------------------------------------------------
---------------------------------- Population Vs Area--------------------------------------------------



Select (Area.IndiaTotalAreaKm2/Pop.PreviousCensusPopulation) as PrevCensusPopArea, (Area.IndiaTotalAreaKm2/Pop.CurrentCensusdata) as CurrCensusPopArea from 
(
(Select '1' as PK, y.*
from(
select SUM(x.PreviousCensusPopulation) as PreviousCensusPopulation, SUM(x.CurrentCensusdata) as CurrentCensusdata
from
        (select h.State, h.District, ROUND((h.PopulationCount/(1+(h.Growth/100))),0) as PreviousCensusPopulation, h.PopulationCount as CurrentCensusdata
        from
            (select a.district, a.state, CAST(Replace(a.Growth,'%','') as float) as Growth, b.PopulationCount
            from dbo.CensusIndia1 a inner join dbo.CensusIndia2 b on a.district = b.district
            ) h
        ) x
) y)Pop

Inner join 
(Select '1' as PK, z.*
from(
select SUM(Area_Km) as IndiaTotalAreaKm2
    from dbo.CensusIndia2) z) Area on Area.PK = Pop.PK)


--------------------------------------------------------------------------------------
--------------------Window Functions --- Top 3 Literacy districts in each state ---------------------------------


select x.* from
(select state,district, literacy,
RANK() OVER(PARTITION BY STATE ORDER BY literacy desc) as Literacyrank from dbo.CensusIndia1)x
where x.Literacyrank in (1,2,3);
