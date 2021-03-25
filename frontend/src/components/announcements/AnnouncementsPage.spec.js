import React from 'react';
import { render } from "@testing-library/react";
import AnnouncementsPage from './index.jsx';

describe("Describes Announcements page", () => {
    it("It renders without crashing", () => {
        const { asFragment } = render(
            <AnnouncementsPage />
        );
        const firstRender = asFragment()

        //debug();
        expect(firstRender).toMatchSnapshot();
    }
    )

});
